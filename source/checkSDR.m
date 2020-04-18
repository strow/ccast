%
% NAME
%   checkSDR -- SDR validation
%
% SYNOPSIS
%   [L1b_err, L1b_stat] = ...
%       checkSDR(vLW, vMW, vSW, rLW, rMW, rSW, cLW, cMW, cSW, ...
%                userLW, userMW, userSW, L1a_err, rid, opts);
%
% INPUTS
%   vLW   - nchan LW frequency
%   vMW   - nchan MW frequency
%   vSW   - nchan SW frequency
%   rLW   - nchan x 9 x 30 x nscan LW radiance
%   rMW   - nchan x 9 x 30 x nscan MW radiance
%   rSW   - nchan x 9 x 30 x nscan SW radiance
%   cLW   - nchan x 9 x 30 x nscan LW complex residual
%   cMW   - nchan x 9 x 30 x nscan MW complex residual
%   cSW   - nchan x 9 x 30 x nscan SW complex residual
%   userLW   - LW user grid specs
%   userMW   - MW user grid specs
%   userSW   - SW user grid specs
%   L1a_err  - 30 x nscan L1a error flags
%   rid      - SDR date and time string
%   opts     - optional parameter struct
%
% opts fields, with defaults
%   emax   - 4, max messages per call
%   bUB    - [350 350 360], [LW MW SW] Tb upper bounds
%   rLB    - [0 -1.0 -0.1], [LW MW SW] radiance lower bounds
%   cLR    - [2 0.88 0.06], low res complex residual bounds
%   cHR    - [2 1.25 0.12], high res complex residual bounds
%
% OUTPUTS
%   L1b_err  - 9 x 30 x nscan L1b error flags
%   L1b_stat - struct with 9 x 30 x nscan error flags
%
% L1b_stat fields 
%   negLW, negMW, negSW - negative radiance
%   nanLW, nanMW, nanSW - NaNs from calibration
%   imgLW, imgMW, imgSW - complex residual too large
%   hotLW, hotMW, hotSW - scene too hot
%   L1b_old - the old 30 x nscan L1b_err flag
%
% DISCUSSION
%   checkSDR sets warning flags for each band for calibration NaNs,
%   negative radiance, complex residuals, and hot scenes.  These are
%   returned as booleans in the L1b_stat struct
%
%   L1b_err is currently set for L1a errors, negative radiance, and
%   calibration NaNs occuring in any band
%
% AUTHOR
%   H. Motteler, 26 Jan 2017
%

function [L1b_err, L1b_stat] = ...
   checkSDR(vLW, vMW, vSW, rLW, rMW, rSW, cLW, cMW, cSW, ...
            userLW, userMW, userSW, L1a_err, rid, opts)

%--------------------
% default parameters
%--------------------
emax = 4;              % max error messages
user_res = 'lowres';   % 'lowres' or 'hires'

% QC limits
bUB = [350 350 360];   % Tb upper bounds
rLB = [0 -1.0 -0.1];   % radiance lower bounds
cLR = [2 0.88 0.06];   % low res complex residual bounds
cHR = [2 0.25 0.12];   % high res complex residual bounds

% apply parameter options
if nargin == 15
  if isfield(opts, 'emax'), emax = opts.emax; end
  if isfield(opts, 'user_res'), user_res = opts.user_res; end
  if isfield(opts, 'bUB'), bUB = opts.bUB; end
  if isfield(opts, 'rLB'), rLB = opts.rLB; end
  if isfield(opts, 'cLR'), cLR = opts.cLR; end
  if isfield(opts, 'cHR'), cHR = opts.cHR; end
end

%----------------
% initialization
%----------------
% error message count
ecnt = 0;

% frequency index for range checks
ixLW = find(userLW.v1 + 10 <= vLW & vLW <= userLW.v2);
ixMW = find(userMW.v1 <= vMW & vMW <= userMW.v2);
ixSW = find(userSW.v1 <= vSW & vSW <= userSW.v2);

% radiance lower bounds
rLBLW = rLB(1);
rLBMW = rLB(2);
rLBSW = rLB(3);

% radiance upper bounds
rUBLW = bt2rad(vLW(ixLW), bUB(1)) * ones(1,9);
rUBMW = bt2rad(vMW(ixMW), bUB(2)) * ones(1,9);
rUBSW = bt2rad(vSW(ixSW), bUB(3)) * ones(1,9);

% complex residual bounds
switch(user_res)
  case {'lowres', 'midres'}
    cLBLW = -cLR(1); cUBLW = cLR(1); 
    cLBMW = -cLR(2); cUBMW = cLR(2);
    cLBSW = -cLR(3); cUBSW = cLR(3);
%   if userSW.dv ~= 2.5
%     error(sprintf('unexpected userSW.dv value %g', userSW.dv));
%   end
  case 'hires',
    cLBLW = -cHR(1); cUBLW = cHR(1); 
    cLBMW = -cHR(2); cUBMW = cHR(2);
    cLBSW = -cHR(3); cUBSW = cHR(3);
%   if userSW.dv ~= 0.625
%     error(sprintf('unexpected userSW.dv value %g', userSW.dv));
%   end
  otherwise
    error(sprintf('unexpected use_res value %s', user_res));
end

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
    rtmpLW = rLW(ixLW,:,i,j);
    ctmpLW = cLW(ixLW,:,i,j);
    rtmpMW = rMW(ixMW,:,i,j);
    ctmpMW = cMW(ixMW,:,i,j);
    rtmpSW = rSW(ixSW,:,i,j);
    ctmpSW = cSW(ixSW,:,i,j);

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
    if emax > 0

      if cOR(nanLW(:,i,j)), err_msg(i,j,'LW NaN'), end
      if cOR(nanMW(:,i,j)), err_msg(i,j,'MW NaN'), end
      if cOR(nanSW(:,i,j)), err_msg(i,j,'SW NaN'), end

%     if cOR(imgLW(:,i,j)), err_msg(i,j,'LW complex residual too large'), end
%     if cOR(imgMW(:,i,j)), err_msg(i,j,'MW complex residual too large'), end
%     if cOR(imgSW(:,i,j)), err_msg(i,j,'SW complex residual too large'), end

      if cOR(negLW(:,i,j)), err_msg(i,j,'LW negative radiance'), end
      if cOR(negMW(:,i,j)), err_msg(i,j,'MW negative radiance'), end
      if cOR(negSW(:,i,j)), err_msg(i,j,'SW negative radiance'), end

%     if cOR(hotLW(:,i,j)), err_msg(i,j,'LW too hot'), end
%     if cOR(hotMW(:,i,j)), err_msg(i,j,'MW too hot'), end
%     if cOR(hotSW(:,i,j)), err_msg(i,j,'SW too hot'), end

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
if emax > 0 && nSDRerr > 0
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

