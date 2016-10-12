%
% NAME
%   calmain_a2 - calmain stub to derive a2 values from ICT and space looks
%
% SYNOPSIS
%   [rcal, vcal, nedn] = ...
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
%   rcal    - nchan x 9 x 30 x nscan, calibrated radiance
%   vcal    - nchan x 1 frequency grid
%   nedn    - nchan x 2 NEdN estimates
%
% DISCUSSION
%   The calibration equation is
%
%     r_obs = F * r_ict * f * SA-1 * f * (ES-SP)/(ICT-SP)
%
%   r_obs - calibrated radiance at the user grid
%   F     - fourier interpolation to the user grid
%   r_ict - expected ICT radiance at the sensor grid
%   f     - raised-cosine bandpass filter
%   SA-1  - inverse of the ILS matrix
%   ES    - earth-scene count spectra
%   IT    - calibration target count spectra
%   SP    - space-look count spectra
%
% AUTHOR
%   H. Motteler, 26 Apr 2012
%

function [rcal, vcal, nedn] = ...
     calmain(inst, user, rcnt, stime, avgIT, avgSP, sci, eng, geo, opts)

%-------------------
% calibration setup
%-------------------

% get the spectral space numeric filter
inst.sNF = specNF(inst, opts.NF_file);

% get key dimensions
[nchan, n, k, nscan] = size(rcnt);

% select band-specific options
switch inst.band
  case 'LW', sfile = opts.LW_sfile; bi = 1;
  case 'MW', sfile = opts.MW_sfile; bi = 2;
  case 'SW', sfile = opts.SW_sfile; bi = 3;
end

% get the SA inverse matrix
Sinv = getSAinv(sfile, inst);

% get the SA forward matrix
[m, n, k] = size(Sinv);
Sfwd = zeros(m, n, k);
for i = 1 : 9
  Sfwd(:, :, i) = inv(Sinv(:, :, i));
end

% get processing filter specs
pL = inst.pL; pH = inst.pH; rL = inst.rL; rH = inst.rH;

% get nlc a2 weights
if isfield(inst, 'a2') && ~isempty(inst.a2)
  a2 = inst.a2;
else
  a2 = eng.Linearity_Param.Band(bi).a2;
end

% get nlc params from eng
cm = eng.Modulation_eff.Band(bi).Eff;
cp = eng.PGA_Gain.Band(bi).map(eng.PGA_Gain.Band(bi).Setting+1);
Vinst = eng.Linearity_Param.Band(bi).Vinst;

% put nlc vectors in column order
a2 = a2(:);
cm = cm(:);
cp = cp(:);
Vinst = Vinst(:);

% analog to digital gain
ca = 8192/2.5;

% set UW nlc fudge factors
switch upper(inst.band)
  case 'LW',  sNF_fudge = 1.6047;
  case 'MW',  sNF_fudge = 0.9826;
  case 'SW',  sNF_fudge = 0.2046;
end

%--------------------------------------------------
% loop on scans with full IT and SP moving averages
%---------------------------------------------------

for si = 5 : nscan - 4
 
  % check that this row has some ES's
  if isnan(max(stime(1:30, si)))
    continue
  end

  % get index of the closest sci record
  dt = abs(max(stime(:, si)) - [sci.time]);
  ix = find(dt == min(dt));

  % get ICT temperature
  T_ICT = (sci(ix).T_PRT1 + sci(ix).T_PRT2) / 2;

  % get expected ICT radiance at the sensor grid
  B = ICTradModel(inst.band, inst.freq, T_ICT, sci(ix), eng.ICT_Param, ...
                  1, NaN, 1, NaN);

  % rename expected ICT radiance
  rIT = B.total(:);

  % load normalized responsivity
  load resp_filt
  switch upper(inst.band)
    case 'LW', resp_filt = filt_lw; resp_freq = freq_lw;
    case 'MW', resp_filt = filt_mw; resp_freq = freq_mw;
    case 'SW', resp_filt = filt_sw; resp_freq = freq_sw;
  end

  % interpolate responsivity to sensor grid
  resp_filt = interp1(resp_freq, resp_filt, inst.freq, 'spline');

  % normalize responsivity to max 1
  resp_filt = resp_filt * 1/max(resp_filt);

  % apply responsivity to expected ICT rad
  rIT = rIT .* resp_filt;

  % normalize numeric filter to max 1
  sNF = inst.sNF / max(inst.sNF);

  %---------
  % a2 calc
  %---------

  % apply forward SA correction to expected ICT rad
  rIT9 = zeros(inst.npts, 9);
  for j = 1 : 9
    rIT9(:, j) = Sfwd(:, :, j) * rIT;
  end

  % apply numeric filter to expected ICT rad
  rIT9 = rIT9 .* (sNF * ones(1, 9));

  % normalize by the DC level
  rIT9 = rIT9 ./ (ones(inst.npts, 1) * mean(rIT9));

  % apply phase correction to complex obs diffs
  obsIT1 =  pcorr2(avgIT(:,:,1,si) - avgSP(:,:,1,si));
  obsIT2 =  pcorr2(avgIT(:,:,2,si) - avgSP(:,:,2,si));

  % normalize by the DC level
  obsIT1 = obsIT1 ./ (ones(inst.npts, 1) * mean(obsIT1));
  obsIT2 = obsIT2 ./ (ones(inst.npts, 1) * mean(obsIT2));

  % calculate residuals
  ax1 =  abs(obsIT1 - rIT9) ./ rIT9;
% ax1 =  abs(obsIT1 - rIT9) ./ (rIT9 .* (ones(inst.npts, 1) * mean(rIT9)));
  ix = find(user.v1 <= inst.freq & inst.freq <= user.v2);
  ax2 = mean(ax1(ix, :));
  ax3 = rms(obsIT1(ix, :) - rIT9(ix, :)) ./ rms(rIT9(ix, :));

  if strcmp(inst.band, 'LW') && si == 21
%   plot(inst.freq, obsIT1 - rIT9)
%   legend(fovnames)
%   bar(ax2)
    keyboard
  end
end

rcal = zeros(inst.npts, 9, 30, nscan);
vcal = inst.freq;
nedn = zeros(inst.npts, 9, 2);

