%
% NAME
%   calmain_a5 - calmain_e7 hacked to dump uncalibrated spectra
%
% SYNOPSIS
%   [rES, rSP, rIT, vcal] = ...
%      calmain(inst, user, rcnt, stime, avgIT, avgSP, sci, eng, geo, opts);
%
% INPUTS
%   inst    - instrument params struct
%   user    - user grid params struct
%   rcnt    - nchan x 9 x 34 x nscan, rad counts
%   stime   - 34 x nscan, rad count times
%   avgIT   - nchan x 9 x 2 x nscan, moving avg IT rad count
%   avgSP   - nchan x 9 x 2 x nscan, moving avg SP rad count
%   sci     - struct array, data from 8-sec science packets
%   eng     - struct, most recent engineering packet
%   geo     - struct, GCRSO fields from geo_match
%   opts    - for now, everything else
%
% OUTPUTS
%   rES     - nchan x 9 x 30 x nscan, uncalibrated ES looks
%   rSP     - nchan x 9 x 2 x nscan, uncalibrated SP looks
%   rIT     - nchan x 9 x 2 x nscan, uncalibrated IT looks
%   vcal    - nchan x 1 frequency grid, from inst.freq
%
% DISCUSSION
%   output namees differ from standard versions of calmain.
%   the flipped parity of IT and SP looks is preserved, so 
%   for  example rES(:, :, 15, 30) matches rSP(:, :, 2, 30).
%

function [rES, rSP, rIT, vcal] = ...
     calmain(inst, user, rcnt, stime, avgIT, avgSP, sci, eng, geo, opts)

%-------------------
% calibration setup
%-------------------

% get the spectral space numeric filter
inst.sNF = specNF(inst, opts.NF_file);

% get key dimensions
[nchan, n, k, nscan] = size(rcnt);

% initialize the output arrays
rES = ones(nchan, 9, 30, nscan) * NaN;
rSP = ones(nchan, 9, 2, nscan) * NaN;
rIT = ones(nchan, 9, 2, nscan) * NaN;

% select band-specific options
switch inst.band
  case 'LW', sfile = opts.LW_sfile; bi = 1; 
  case 'MW', sfile = opts.MW_sfile; bi = 2;
  case 'SW', sfile = opts.SW_sfile; bi = 3;
end

% get the SA inverse matrix
Sinv = getSAinv(sfile, inst);

% get processing filter specs
pL = inst.pL; pH = inst.pH; rL = inst.rL; rH = inst.rH;

% build the resampling matrix
[R, vcal] = resamp(inst, user, opts.resamp);

% get nlc params from eng
cm = eng.Modulation_eff.Band(bi).Eff;
cp = eng.PGA_Gain.Band(bi).map(eng.PGA_Gain.Band(bi).Setting+1);
Vinst = eng.Linearity_Param.Band(bi).Vinst;
cm = cm(:); cp = cp(:); Vinst = Vinst(:);

% analog to digital gain
ca = 8192/2.5;

% combined gain factor
cg = cm .* cp * ca * inst.df / 2;

%---------------
% loop on scans
%---------------

for si = 1 : nscan 
 
  % check that this row has some ES's
  if isnan(max(stime(1:30, si)))
    continue
  end

% % get index of the closest sci record
% dt = abs(max(stime(:, si)) - [sci.time]);
% ix = find(dt == min(dt));
%
% % get ICT temperature
% T_ICT = (sci(ix).T_PRT1 + sci(ix).T_PRT2) / 2;
%
% % get expected ICT radiance at the sensor grid
% B = ICTradModel(inst.band, inst.freq, T_ICT, sci(ix), eng.ICT_Param, ...
%                 1, NaN, 1, NaN);
%
% % copy rIT across 30 columns
% rIT = B.total(:) * ones(1, 30);

  %-------------------------
  % earth scene calibration
  %-------------------------

  % loop on sweep direction
  for j = 1 : 2

    % divide by numeric filter and gain factors
    rtmp = avgSP(:,:,j,si);
    rtmp = rtmp ./ (inst.sNF(:) * ones(1, 9));
    rtmp = rtmp ./ (ones(inst.npts, 1) * cg');  
    rSP(:, :, j, si) = rtmp;

    rtmp = avgIT(:,:,j,si);
    rtmp = rtmp ./ (inst.sNF(:) * ones(1, 9));
    rtmp = rtmp ./ (ones(inst.npts, 1) * cg');  
    rIT(:, :, j, si) = rtmp;

  end

  % loop on earth scenes
  for iES = 1 : 30

    % divide by numeric filter and gain factors
    rtmp = rcnt(:, :, iES, si);
    rtmp = rtmp ./ (inst.sNF(:) * ones(1, 9));
    rtmp = rtmp ./ (ones(inst.npts, 1) * cg');  
    rES(:, :, iES, si) = rtmp;

%   % apply the UW nonlinearlity correction
%   j = mod(iES, 2) + 1; % SP and IT index
%   rES(:, :, iES, si) = ...
%     nlc_new(inst, rcnt(:, :, iES, si), avgSP(:, :, j, si), eng);

  end
end

vcal = inst.freq;

