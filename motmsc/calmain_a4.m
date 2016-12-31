%
% NAME
%   calmain_a4 - calmain stub for nonlinearity and related tests
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
  case 'LW', sfile = opts.LW_sfile; bi = 1; UW_NF_scale = 1.6047;
  case 'MW', sfile = opts.MW_sfile; bi = 2; UW_NF_scale = 0.9826;
  case 'SW', sfile = opts.SW_sfile; bi = 3; UW_NF_scale = 0.2046;
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
a2 = a2(:); 

% get nlc params from eng
cm = eng.Modulation_eff.Band(bi).Eff;
cp = eng.PGA_Gain.Band(bi).map(eng.PGA_Gain.Band(bi).Setting+1);
Vinst = eng.Linearity_Param.Band(bi).Vinst;
cm = cm(:); cp = cp(:); Vinst = Vinst(:);

% analog to digital gain
ca = 8192/2.5;

% combined gain factor
cg = cm .* cp * ca * inst.df / 2;

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

%--------------------------------------------------
% loop on scans with full IT and SP moving averages
%---------------------------------------------------

for si = 1 : nscan
 
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
    case 'LW', rsf = 260;   % from IT - SP
    case 'MW', rsf = 160;   % from IT - SP
    case 'SW', rsf = 100;   % arbitrary
  end
  vIT9f = rIT9f / rsf;
  vIT9r = rIT9r / rsf;

  % select an earth-scene
  iES = 15; 
% iES = 16; 
  j = mod(iES, 2) + 1;

  % divide by the numeric filter
  specIT = avgIT(:,:,j,si) ./ (inst.sNF(:) * ones(1, 9));
  specSP = avgSP(:,:,j,si) ./ (inst.sNF(:) * ones(1, 9));
  specES = rcnt(:,:,iES,si) ./ (inst.sNF(:) * ones(1, 9));

  % divide by gain factors
  specIT = specIT ./ (ones(inst.npts, 1) * cg');
  specSP = specSP ./ (ones(inst.npts, 1) * cg');
  specES = specES ./ (ones(inst.npts, 1) * cg');

  % spectra differences
  specIT_SP = specIT - specSP;
  specES_SP = specES - specSP;

  % spectra complex modulus
  absIT_SP = abs(specIT_SP);
  absES_SP = abs(specES_SP);

  % level means
  levIT = mean(abs(specIT))';
  levSP = mean(abs(specSP))';
  levES = mean(abs(specES))';
  levIT_SP = mean(absIT_SP)';
  levES_SP = mean(absES_SP)';
% [Vinst levSP levIT levES levIT_SP levES_SP]

  % basic calibration ratio
  cal_ratio = (specES - specSP) ./ (specIT - specSP);

 %---------------------
 % set pause condition
 %---------------------

% if ~(strcmp(inst.band, 'MW') && si == 2), continue, end   % hot
  if ~(strcmp(inst.band, 'LW') && si == 21), continue, end  % warmer
% if ~(strcmp(inst.band, 'MW') && si == 59), continue, end  % cold

  fprintf(1, '*** %s scan %d FOR %d pause ***\n', inst.band, si, iES)

  %----------------
  % interferograms
  %----------------

  igmES = spec2igm(specES, inst);
  igmIT = spec2igm(specIT, inst);
  igmSP = spec2igm(specSP, inst);
  igmES_SP = spec2igm(specES_SP, inst);
  igmIT_SP = spec2igm(specIT_SP, inst);

% [levIT_SP, max(abs(igmIT_SP))', levES_SP, max(abs(igmES_SP))']
% [(levIT_SP - max(abs(igmIT_SP))') ./ levIT_SP, ...
%  (levES_SP - max(abs(igmES_SP))') ./ levES_SP]

  figure(1); clf
  jx = 1 : inst.npts;
  plot(jx, abs(igmIT_SP))
% axis([526, 528, 0.09, 0.12])
  title([inst.band, ' IT - SP complex modulus'])
  grid on

  keyboard

  %----------------------------
  % basic ES, SP, and IT plots
  %----------------------------

  % ES magnitude and components
  figure(1); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
  subplot(3,1,1)
  plot(inst.freq, abs(specES));
% axis([660, 680, 0, 0.5])
  title('ES magnitude')
  legend(fovnames, 'location', 'eastoutside')
  ylabel('volts')
  grid on;

  subplot(3,1,2)
  plot(inst.freq, real(specES))
% axis([660, 680, -0.3,  0.2])
  title('ES real')
  legend(fovnames, 'location', 'eastoutside')
  ylabel('volts')
  grid on;

  subplot(3,1,3)
  plot(inst.freq, imag(specES))
% axis([660, 680, -0.2,  0.3])
  title('ES imag')
  legend(fovnames, 'location', 'eastoutside')
  xlabel('wavenumber')
  ylabel('volts')
  grid on;

  % IT magnitude and components
  figure(2); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
  subplot(3,1,1)
  plot(inst.freq, abs(specIT));
% axis([660, 680, 0, 0.5])
  title('IT magnitude')
  legend(fovnames, 'location', 'eastoutside')
  ylabel('volts')
  grid on;

  subplot(3,1,2)
  plot(inst.freq, real(specIT))
% axis([660, 680, -0.3,  0.2])
  title('IT real')
  legend(fovnames, 'location', 'eastoutside')
  ylabel('volts')
  grid on;

  subplot(3,1,3)
  plot(inst.freq, imag(specIT))
% axis([660, 680, -0.2,  0.3])
  title('IT imag')
  legend(fovnames, 'location', 'eastoutside')
  xlabel('wavenumber')
  ylabel('volts')
  grid on;

  % SP magnitude and components
  figure(3); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
  subplot(3,1,1)
  plot(inst.freq, abs(specSP));
% axis([660, 680, 0, 2])
  title('SP magnitude')
  legend(fovnames, 'location', 'eastoutside')
  ylabel('volts')
  grid on;

  subplot(3,1,2)
  plot(inst.freq, real(specSP))
% axis([660, 680, -1.5,  0])
  title('SP real')
  legend(fovnames, 'location', 'eastoutside')
  ylabel('volts')
  grid on;

  subplot(3,1,3)
  plot(inst.freq, imag(specSP))
% axis([660, 680, 0,  1.5])
  title('SP imag')
  legend(fovnames, 'location', 'eastoutside')
  xlabel('wavenumber')
  ylabel('volts')
  grid on;

  % ES - SP magnitude and components
  figure(4); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
  subplot(3,1,1)
  plot(inst.freq, abs(specES - specSP))
% axis([660, 680, 0.4, 0.6])
  title('ES - SP magnitude')
  legend(fovnames, 'location', 'eastoutside')
  ylabel('volts')
  grid on;

  subplot(3,1,2)
  plot(inst.freq, real(specES - specSP))
% axis([660, 680, 0.4, 0.6])
  title('ES - SP real')
  legend(fovnames, 'location', 'eastoutside')
  ylabel('volts')
  grid on;

  subplot(3, 1, 3)
  plot(inst.freq, imag(specES - specSP))
% axis([660, 680, -0.01, 0.01])
  title('ES - SP imag')
  legend(fovnames, 'location', 'eastoutside')
  grid on;

  keyboard

  %--------------------
  % IT obs minus calc
  %--------------------

  % user grid index
  ix = find(user.v1 <= inst.freq & inst.freq <= user.v2);

  % absolute
  y1 = absIT_SP - vIT9r;
  figure(1); clf
  plot(inst.freq(ix), y1(ix, :));
  title([inst.band, ' (IT - SP) - calc'])
  legend(fovnames, 'location', 'southeast')
  xlabel('frequency')
  ylabel('dV')
  grid on

  % relative
  y1 = (absIT_SP - vIT9r) ./ vIT9r;
  figure(2); clf
  plot(inst.freq(ix), y1(ix, :));
  title([inst.band, ' ((IT - SP) - calc) / calc'])
  legend(fovnames, 'location', 'southeast')
  xlabel('frequency')
  ylabel('relative difference')
  grid on

  keyboard

  %------------------------------
  % solve for UW-style a2 values
  %------------------------------

  % UW scaling factor
  UW_fudge = max(inst.sNF) / UW_NF_scale;

  % get the DC level
  Vdc = Vinst + UW_fudge * mean(abs(specIT - specSP))';

  % solve for a2 values
  a2v = (vIT9r - absIT_SP) ./ (2 * absIT_SP .* (ones(inst.npts, 1) * Vdc'));

  % user grid index
  ix = find(user.v1 <= inst.freq & inst.freq <= user.v2);

  figure(1); clf
  plot(inst.freq(ix), a2v(ix, :))
  title([inst.band, ' a2 values from ICT obs and calc'])
  legend(fovnames, 'location', 'southeast')
  xlabel('frequency')
  ylabel('weight')
  grid on

  a2 = mean(a2v(ix, :));
  figure(2); clf
  bar(a2 - min(a2))
  title([inst.band, ' mean a2 from ICT obs and calc'])
  xlabel('FOV')
  ylabel('weight')
  grid on

  keyboard

  %--------------
  % responsivity
  %--------------

  % plot responsivity, (IT - SP) / vIT9f
  resp_obs = absIT_SP ./ vIT9f;
  figure(1); clf
  plot(inst.freq, resp_obs)
  ax = axis; ax(3) = 0; axis(ax);
  title([inst.band, ' measured responsivity'])
  legend(fovnames, 'location', 'south')
  xlabel('frequency')
  ylabel('weight')
  grid on

  % compare with tabulated responsivity
  y3 =  resp_obs - resp_filt * ones(1, 9);
  figure(2); clf
  plot(inst.freq(ix), y3(ix, :));
  title([inst.band, ' responsivity obs - calc'])
  legend(fovnames, 'location', 'south')
  xlabel('frequency')
  ylabel('difference')
  grid on

  keyboard

end

rcal = zeros(inst.npts, 9, 30, nscan);
vcal = inst.freq;
nedn = zeros(inst.npts, 9, 2);

