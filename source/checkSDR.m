%
% NAME
%   checkSDR -- SDR validation
%
% SYNOPSIS
%   [L1b_err, L1b_stat] = ...
%     checkSDR(vLW, vMW, vSW, rLW, rMW, rSW, cLW, cMW, cSW, L1a_err, rid, opts);
%
% INPUTS
%   vLW     - nchan LW frequency
%   vMW     - nchan MW frequency
%   vSW     - nchan SW frequency
%   rLW     - nchan x 9 x 30 x nscan LW radiance
%   rMW     - nchan x 9 x 30 x nscan MW radiance
%   rSW     - nchan x 9 x 30 x nscan SW radiance
%   cLW     - nchan x 9 x 30 x nscan LW complex residual
%   cMW     - nchan x 9 x 30 x nscan MW complex residual
%   cSW     - nchan x 9 x 30 x nscan SW complex residual
%   L1a_err - 30 x nscan L1a error flags
%   rid     - SDR date and time string
%   opts    - optional parameter struct
%
% opts fields, with defaults
%   emsg   - true, false to turn off messages
%   emax   - 4, max messages to print if emsg is true
%   bUB    - [350 350 360], [LW MW SW] brightness temp upper bounds
%   rLB    - [0 -1.0 -0.1], [LW MW SW] radiance lower bounds
%   swLR   - [10, 11, 14],  [LW MW SW] low res std multiples
%   swHR   - [10, 10, 12],  [LW MW SW] high res std multiples
%   imag_stats_LR  - 'imag_stats_LR', low res complex resid stats
%   imag_stats_HR  - 'imag_stats_HR', high res complex resid stats
%
% OUTPUTS
%   L1b_err  - 9 x 30 x nscan L1b error flags
%   L1b_stat - struct with 9 x 30 x nscan error flags
%
% L1b_stat fields 
%   imgLW, imgMW, imgSW - complex residual too large
%   negLW, negMW, negSW - negative radiance
%   hotLW, hotMW, hotSW - scene too hot
%   nanLW, nanMW, nanSW - NaNs from calibration
%   L1b_old - the old 30 x nscan L1b_err flag
%
% DISCUSSION
%   Complex residual, negative radiance, hot scene, and NaN checks.
%
%   L1a_err is set in rdr2sdr and flags bad time and geo values
%
%   L1b_err is currently set for L1a errors, negative radiance too
%   large, and calibration NaNs.
%
%   The complex residual test uses a mean and standard deviation
%   from files imag_stat_LR and HR in ccast/inst_data.  The complex
%   residual std bounds swLR and swHR are multiples of the standard
%   deviation, for example mean +- swLR * std.
%
% AUTHOR
%   H. Motteler, 26 Jan 2017
%

function [L1b_err, L1b_stat] = ...
    checkSDR(vLW, vMW, vSW, rLW, rMW, rSW, cLW, cMW, cSW, L1a_err, rid, opts)

%--------------------
% default parameters
%--------------------
% error messages
emsg = true;
emax = 4;
ecnt = 0;

% brightness temp upper bounds
bUB = [350 350 360];

% radiance lower bounds
rLB = [0 -1.0 -0.1];

% complex residual stats
imag_stats_LR = '/asl/packages/ccast/inst_data/imag_stats_LR';
imag_stats_HR = '/asl/packages/ccast/inst_data/imag_stats_HR';

% complex residual std bounds
swLR = [10, 12, 16];  % low res [LW MW SW] std multiples
swHR = [10, 10, 12];  % high res [LW MW SW] std multiples

% apply recognized parameter options
if nargin == 12
  if isfield(opts, 'emsg'), emsg = opts.emsg; end
  if isfield(opts, 'emax'), emax = opts.emax; end

  if isfield(opts, 'bUBLW'), bUBLW = opts.bUBLW; end
  if isfield(opts, 'bUBMW'), bUBMW = opts.bUBMW; end
  if isfield(opts, 'bUBSW'), bUBSW = opts.bUBSW; end

  if isfield(opts, 'rLBLW'), rLBLW = opts.rLBLW; end
  if isfield(opts, 'rLBMW'), rLBMW = opts.rLBMW; end
  if isfield(opts, 'rLBSW'), rLBSW = opts.rLBSW; end

  if isfield(opts, 'imag_stats_LR'), imag_stats_LR = opts.imag_stats_LR; end
  if isfield(opts, 'imag_stats_HR'), imag_stats_HR = opts.imag_stats_HR; end

  if isfield(opts, 'swLR'), swLR = opts.swLR; end
  if isfield(opts, 'swHR'), swHR = opts.swHR; end
end

%----------------
% initialization
%----------------
% radiance upper bounds
rUBLW = bt2rad(vLW, bUB(1)) * ones(1,9);
rUBMW = bt2rad(vMW, bUB(2)) * ones(1,9);
rUBSW = bt2rad(vSW, bUB(3)) * ones(1,9);

% radiance lower bounds
rLBLW = rLB(1);
rLBMW = rLB(2);
rLBSW = rLB(3);

% choose complex residual bounds by res mode
switch length(vSW)
  case 163, ftmp = imag_stats_LR; sw = swLR;
  case 637, ftmp = imag_stats_HR; sw = swHR;
  otherwise, error(sprintf('unexpected SW size %d', length(vSW)));
end

% load stats and get complex residual bounds
d1 = load(ftmp);
cUBLW = d1.cmLW + sw(1) * d1.csLW;
cLBLW = d1.cmLW - sw(1) * d1.csLW;
cUBMW = d1.cmMW + sw(2) * d1.csMW;
cLBMW = d1.cmMW - sw(2) * d1.csMW;
cUBSW = d1.cmSW + sw(3) * d1.csSW;
cLBSW = d1.cmSW - sw(3) * d1.csSW;
clear d1

% initialize output
[~, ~, ~, nscan] = size(rLW);
falseA = logical(zeros(9, 30, nscan));
L1b_err = falseA; L1b_old = falseA;
imgLW = falseA; imgMW = falseA; imgSW = falseA;
negLW = falseA; negMW = falseA; negSW = falseA;
hotLW = falseA; hotMW = falseA; hotSW = falseA;
nanLW = falseA; nanMW = falseA; nanSW = falseA;

%------------------------
% loop on scans and FORs
%------------------------
for j = 1 : nscan
  for i = 1 : 30

    % skip checks if we have an L1a error
    if L1a_err(i,j)
      L1b_err(:,i,j) = true;
      L1b_old(:,i,j) = true;
      continue
    end

    % temp vars for this FOR
    rtmpLW = rLW(:,:,i,j);
    rtmpMW = rMW(:,:,i,j);
    rtmpSW = rSW(:,:,i,j);
    ctmpLW = cLW(:,:,i,j);
    ctmpMW = cMW(:,:,i,j);
    ctmpSW = cSW(:,:,i,j);

    % check for NaNs
    nanLW(:,i,j) = cOR(isnan(rtmpLW)) | cOR(isnan(ctmpLW));
    nanMW(:,i,j) = cOR(isnan(rtmpMW)) | cOR(isnan(ctmpMW));
    nanSW(:,i,j) = cOR(isnan(rtmpMW)) | cOR(isnan(ctmpSW));
    if cOR(nanLW(:,i,j)) | cOR(nanMW(:,i,j)) | cOR(nanSW(:,i,j))
      L1b_err(:,i,j) = true;
      L1b_old(:,i,j) = true;
      continue
    end

    % complex residual check
    imgLW(:,i,j) = cOR(ctmpLW < cLBLW | cUBLW < ctmpLW);
    imgMW(:,i,j) = cOR(ctmpMW < cLBMW | cUBMW < ctmpMW);
    imgSW(:,i,j) = cOR(ctmpSW < cLBSW | cUBSW < ctmpSW);

    % negative radiance check
    negLW(:,i,j) = cOR(rtmpLW < rLBLW);
    negMW(:,i,j) = cOR(rtmpMW < rLBMW);
    negSW(:,i,j) = cOR(rtmpSW < rLBSW);

    % hot scene check
    hotLW(:,i,j) = cOR(rUBLW < rtmpLW);
    hotMW(:,i,j) = cOR(rUBMW < rtmpMW);
    hotSW(:,i,j) = cOR(rUBSW < rtmpSW);

    % set summary flags
    L1b_err(:,i,j) = ...
      nanLW(:,i,j) | nanMW(:,i,j) | nanSW(:,i,j) | ...
      negLW(:,i,j) | negMW(:,i,j) | negSW(:,i,j);

    L1b_old(:,i,j) = ...
      nanLW(:,i,j) | nanMW(:,i,j) | nanSW(:,i,j) | ...
      negLW(:,i,j) | negMW(:,i,j) | negSW(:,i,j) | ...
      hotLW(:,i,j) | hotMW(:,i,j) | hotSW(:,i,j);

    % error messages
    if emsg

      if cOR(nanLW(:,i,j)), err_msg(i,j,'LW NaN'), end
      if cOR(nanMW(:,i,j)), err_msg(i,j,'MW NaN'), end
      if cOR(nanSW(:,i,j)), err_msg(i,j,'SW NaN'), end

      if cOR(imgLW(:,i,j)), err_msg(i,j,'LW complex residual too large'), end
      if cOR(imgMW(:,i,j)), err_msg(i,j,'MW complex residual too large'), end
      if cOR(imgSW(:,i,j)), err_msg(i,j,'SW complex residual too large'), end

      if cOR(negLW(:,i,j)), err_msg(i,j,'LW negative radiance'), end
      if cOR(negMW(:,i,j)), err_msg(i,j,'MW negative radiance'), end
      if cOR(negSW(:,i,j)), err_msg(i,j,'SW negative radiance'), end

      if cOR(hotLW(:,i,j)), err_msg(i,j,'LW too hot'), end
      if cOR(hotMW(:,i,j)), err_msg(i,j,'MW too hot'), end
      if cOR(hotSW(:,i,j)), err_msg(i,j,'SW too hot'), end

    end
  end
end

%-----------
% finish up
%-----------
% total bad SDR FORs
nRDRerr = sum(L1a_err(:));
etmp = cOR(L1b_err);
nSDRerr = sum(etmp(:)) - nRDRerr;
if emsg && nSDRerr > 0
  fprintf(1, 'checkSDR: %s %d RDR errors, %d SDR errors\n', ...
          rid, nRDRerr, nSDRerr)
end

% copy logical arrays to output struct
L1b_stat.L1b_old = cOR(L1b_old);
L1b_stat.nanLW = nanLW;
L1b_stat.nanMW = nanMW;
L1b_stat.nanSW = nanSW;
L1b_stat.imgLW = imgLW;
L1b_stat.imgMW = imgMW;
L1b_stat.imgSW = imgSW;
L1b_stat.negLW = negLW;
L1b_stat.negMW = negMW;
L1b_stat.negSW = negSW;
L1b_stat.hotLW = hotLW;
L1b_stat.hotMW = hotMW;
L1b_stat.hotSW = hotSW;
L1b_stat.cUBLW = cUBLW;
L1b_stat.cLBLW = cLBLW;
L1b_stat.cUBMW = cUBMW;
L1b_stat.cLBMW = cLBMW;
L1b_stat.cUBSW = cUBSW;
L1b_stat.cLBSW = cLBSW;

%----------------------
% print error messages
%----------------------
function err_msg(i, j, msg)

  if ecnt < emax
    fprintf(1, 'checkSDR: %s scan %d FOR %d, %s\n', rid, j, i, msg)
    ecnt = ecnt + 1;
  elseif ecnt == emax
    fprintf(1, 'checkSDR: %s error message limit...\n', rid)
    ecnt = ecnt + 1;
  end

end % err_msg

end % checkSDR

