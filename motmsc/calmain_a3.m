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

% combined gain factor 
cg = cm .* cp .* ca;

%--------------------------------------------------
% loop on scans with full IT and SP moving averages
%---------------------------------------------------

for si = 5 : nscan - 4
 
  % check that this row has some ES's
  if isnan(max(stime(1:30, si)))
    continue
  end

  % just spin until we get to desired scan
  if ~(strcmp(inst.band, 'LW') && si == 31)
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
  rITr = rIT .* resp_filt;

  % apply forward SA correction to expected ICT rad
  rIT9f = zeros(inst.npts, 9);  % f = flat
  rIT9r = zeros(inst.npts, 9);  % r = resp
  for j = 1 : 9
    rIT9f(:, j) = Sfwd(:, :, j) * rIT;
    rIT9r(:, j) = Sfwd(:, :, j) * rITr;
  end

  % ad hoc conversion of rIT9 to volts 
  switch inst.band
    case 'LW', rsf = 20;
    case 'MW', rsf = 16;
    otherwise, rsf = 1;
  end
  vIT9f = rIT9f / rsf;
  vIT9r = rIT9r / rsf;

  % divide by the numeric filter
  specIT = avgIT(:,:,1,si) ./ (inst.sNF(:) * ones(1, 9));
  specSP = avgSP(:,:,1,si) ./ (inst.sNF(:) * ones(1, 9));

  % divide by gain factors
  specIT = specIT ./ (ones(inst.npts, 1) * cg');
  specSP = specSP ./ (ones(inst.npts, 1) * cg');

  % IT - SP diff and phase corr
  specXX = pcorr2(specIT - specSP);

  % user grid index
  ix = find(user.v1 <= inst.freq & inst.freq <= user.v2);

  % basic residuals
% y1 = specXX - vIT9r;
  y1 = (specXX - vIT9r) ./ vIT9r;
  figure(1); clf
  plot(inst.freq(ix), y1(ix, :));
% title([inst.band, ' (IT - SP) - calc'])
  title([inst.band, ' ((IT - SP) - calc) / calc'])
  legend(fovnames, 'location', 'southeast')
  xlabel('frequency')
  ylabel('relative difference')
% ylabel('volts')
  grid on

  % apply UW nonlin correction
  tmpIT = avgIT(:,:,1,si) ./ (inst.sNF(:) * ones(1, 9));
  tmpSP = avgSP(:,:,1,si) ./ (inst.sNF(:) * ones(1, 9));
  nlcIT = nlc_fwd(inst, tmpIT, tmpSP, eng);
  nlcSP = nlc_fwd(inst, tmpSP, tmpSP, eng);

  % divide by gain factors
  nlcIT = nlcIT ./ (ones(inst.npts, 1) * cg');
  nlcSP = nlcSP ./ (ones(inst.npts, 1) * cg');

  % IT - SP diff and phase corr
  nlcXX = pcorr2(nlcIT - nlcSP);

  % UW correction residuals
  y4 =  (nlcXX - vIT9r) ./vIT9r;
  figure(2); clf
  plot(inst.freq(ix), y4(ix, :));
  title([inst.band, ' UW NLC ((IT - SP) - calc) / calc'])
  legend(fovnames, 'location', 'southeast')
  xlabel('frequency')
  ylabel('relative difference')
  grid on

  % direct calc of correction factor
  r1 = specXX ./ vIT9r;
  r2 = mean(r1(ix, :));
  specYY = specXX ./ (ones(inst.npts, 1) * r2);
  y2 = (specYY - vIT9r) ./ vIT9r;
  figure(3); clf
  plot(inst.freq(ix), y2(ix, :));
  title([inst.band, ' scaling NLC ((IT - SP) - calc) / calc'])
  legend(fovnames, 'location', 'southeast')
  xlabel('frequency')
  ylabel('relative difference')
  grid on

  keyboard

  % plot responsivity, (IT - SP) / vIT9f
  resp_obs = specXX ./ vIT9f;
  figure(4); clf
  plot(inst.freq, resp_obs)
  ax = axis; ax(3) = 0; axis(ax);
  title([inst.band, ' measured responsivity'])
  legend(fovnames, 'location', 'south')
  xlabel('frequency')
  ylabel('weight')
  grid on

  % compare with tabulated responsivity
  y3 =  resp_obs - resp_filt * ones(1, 9);
  figure(5); clf
  plot(inst.freq(ix), y3(ix, :));
  title([inst.band, ' responsivity obs - calc'])
  legend(fovnames, 'location', 'south')
  xlabel('frequency')
% ylabel('relative difference')
  grid on

end

rcal = zeros(inst.npts, 9, 30, nscan);
vcal = inst.freq;
nedn = zeros(inst.npts, 9, 2);

