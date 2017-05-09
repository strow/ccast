%
% NAME
%   checkSDR -- SDR validation
%
% SYNOPSIS
%   L1b_err = ...
%     checkSDR(vLW, vMW, vSW, rLW, rMW, rSW, cLW, cMW, cSW, L1a_err, rid);
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
%
% OUTPUTS
%   L1b_err  - 30 x nscan L1b error flags
%   L1b_stat - struct for error status info
%
% DISCUSSION
%   complex residual, negative radiance, hot scene, and NaN checks 
%
% AUTHOR
%   H. Motteler, 26 Jan 2017
%

function [L1b_err, L1b_stat] = ...
         checkSDR(vLW, vMW, vSW, rLW, rMW, rSW, cLW, cMW, cSW, L1a_err, rid)

% error messages
emsg = true;
ecnt = 0;
emax = 10;

% radiance upper bounds
rUBLW = bt2rad(vLW, 350) * ones(1, 9);
rUBMW = bt2rad(vMW, 350) * ones(1, 9);
rUBSW = bt2rad(vSW, 360) * ones(1, 9);

% radiance lower bounds
rLBLW =  0;
rLBMW = -1.0;
rLBSW = -0.1;

% complex residual bounds
d1 = load('imag_stats_t11');
kLW = 10; kMW = 10; kSW = 12;
cUBLW = d1.cmLW + kLW * d1.csLW;
cLBLW = d1.cmLW - kLW * d1.csLW;
cUBMW = d1.cmMW + kMW * d1.csMW;
cLBMW = d1.cmMW - kMW * d1.csMW;
cUBSW = d1.cmSW + kSW * d1.csSW;
cLBSW = d1.cmSW - kSW * d1.csSW;
clear d1

% initialize output
[~, ~, ~, nscan] = size(rLW);
Lfalse = logical(zeros(30, nscan));
L1b_err = Lfalse; L1b_old = Lfalse;
imgLW = Lfalse; imgMW = Lfalse; imgSW = Lfalse;
negLW = Lfalse; negMW = Lfalse; negSW = Lfalse;
hotLW = Lfalse; hotMW = Lfalse; hotSW = Lfalse;
nanLW = Lfalse; nanMW = Lfalse; nanSW = Lfalse;

% loop on scans and FORs
for j = 1 : nscan
  for i = 1 : 30

    % no check if we have an L1a error
    if L1a_err(i,j)
      L1b_err(i,j) = true;
      continue
    end

    % temp vars for this FOR
    rtmpLW = rLW(:, :, i, j);
    rtmpMW = rMW(:, :, i, j);
    rtmpSW = rSW(:, :, i, j);
    ctmpLW = cLW(:, :, i, j);
    ctmpMW = cMW(:, :, i, j);
    ctmpSW = cSW(:, :, i, j);

    % check for NaNs
    nanLW(i,j) = ~isempty(find(isnan(rtmpLW)));
    nanMW(i,j) = ~isempty(find(isnan(rtmpMW)));
    nanSW(i,j) = ~isempty(find(isnan(rtmpSW)));
%   if nanLW(i,j) || nanMW(i,j) || nanSW(i,j)
%     L1b_err(i,j) = true;
%     continue
%   end

    % complex residual check
    imgLW(i,j) = ~isempty(find(ctmpLW < cLBLW | cUBLW < ctmpLW));
    imgMW(i,j) = ~isempty(find(ctmpMW < cLBMW | cUBMW < ctmpMW));
    imgSW(i,j) = ~isempty(find(ctmpSW < cLBSW | cUBSW < ctmpSW));

    % negative radiance check
    negLW(i,j) = ~isempty(find(rtmpLW < rLBLW));
    negMW(i,j) = ~isempty(find(rtmpMW < rLBMW));
    negSW(i,j) = ~isempty(find(rtmpSW < rLBSW));

    % hot scene check
    hotLW(i,j) = ~isempty(find(rUBLW < rtmpLW));
    hotMW(i,j) = ~isempty(find(rUBMW < rtmpMW));
    hotSW(i,j) = ~isempty(find(rUBSW < rtmpSW));

    % set summary flags
    L1b_err(i,j) = ...
      nanLW(i,j) || nanMW(i,j) || nanSW(i,j) || ...
      imgLW(i,j) || imgMW(i,j) || imgSW(i,j) || ...
      negLW(i,j) || negMW(i,j) || negSW(i,j);

    L1b_old(i,j) = ...
      nanLW(i,j) || nanMW(i,j) || nanSW(i,j) || ...
      negLW(i,j) || negMW(i,j) || negSW(i,j) || ...
      hotLW(i,j) || hotMW(i,j) || hotSW(i,j);

    % error messages
    if emsg

      if nanLW(i,j), err_msg(i,j, 'LW NaN'), end
      if nanMW(i,j), err_msg(i,j, 'MW NaN'), end
      if nanSW(i,j), err_msg(i,j, 'SW NaN'), end

      if imgLW(i,j), err_msg(i,j, 'LW complex residual too large'), end
      if imgMW(i,j), err_msg(i,j, 'MW complex residual too large'), end
      if imgSW(i,j), err_msg(i,j, 'SW complex residual too large'), end

      if negLW(i,j), err_msg(i,j, 'LW negative radiance'), end
      if negMW(i,j), err_msg(i,j, 'MW negative radiance'), end
      if negSW(i,j), err_msg(i,j, 'SW negative radiance'), end

      if hotLW(i,j), err_msg(i,j, 'LW too hot'), end
      if hotMW(i,j), err_msg(i,j, 'MW too hot'), end
      if hotSW(i,j), err_msg(i,j, 'SW too hot'), end

    end
  end
end

% total bad FORs
nRDRerr = sum(L1a_err(:));
nSDRerr = sum(L1b_err(:)) - nRDRerr;
if nSDRerr > 0
  fprintf(1, 'checkSDR: %s %d RDR errors, %d SDR errors\n', ...
          rid, nRDRerr, nSDRerr)
end

% copy lgical arrays to output struct
L1b_stat.L1b_old = L1b_old;
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

% print error messages
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

