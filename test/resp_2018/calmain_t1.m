%
% NAME
%   calmain_t1 - nonlinearity tests
%
% SYNOPSIS
%   [rcal, vcal, nedn] = ...
%     calmain(inst, user, rcnt, avgIT, avgSP, sci, eng, geo, opts);
%
% INPUTS
%   inst    - instrument params struct
%   user    - user grid params struct
%   rcnt    - nchan x 9 x 34 x nscan, rad counts
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
  calmain(inst, user, rcnt, avgIT, avgSP, sci, eng, geo, opts)

%-------------------
% calibration setup
%-------------------

% get key dimensions
[nchan, n, k, nscan] = size(rcnt);

% initialize the output array
rcal = ones(nchan, 9, 30, nscan) * NaN;

% initialize working arrays
es_nlc = ones(nchan, 9) * NaN;
sp_nlc = ones(nchan, 9, 2) * NaN;
it_nlc = ones(nchan, 9, 2) * NaN;
es_sp = ones(nchan, 9, 30) * NaN;
it_sp = ones(nchan, 9, 2) * NaN;

% NLC setup
nopt = nlc_opts(inst, eng, opts);

% NEdN setup
rICT = ones(nchan, 9, 2, nscan) * NaN;
sp_all = rcnt(:, :, 31:32, :);
it_all = rcnt(:, :, 33:34, :);
sp_mean = nanmean(sp_all, 4);
it_mean = nanmean(it_all, 4);

% get the SA inverse matrix
Sinv = getSAinv(inst, opts);

% get the SA forward matrix
[m, n, k] = size(Sinv);
Sfwd = zeros(m, n, k);
for i = 1 : 9
  Sfwd(:, :, i) = inv(Sinv(:, :, i));
end

% get processing filter specs
pL = inst.pL; pH = inst.pH; rL = inst.rL; rH = inst.rH;

% build the resampling matrix
[R, vcal] = resamp(inst, user, opts.resamp);

% initialize outputs
[~,~,~,nscan] = size(rcnt);
vcal = inst.freq;
rcal = NaN(m,9,30,nscan);
nedn = NaN(m,9,2);

% pick a band for tests
% if ~strcmp(inst.band, 'LW'), return, end;
  if ~strcmp(inst.band, 'SW'), return, end;
display([inst.band, ' ', datestr(iet2dnum(geo.FORTime(1)))])

% loop on sweep directions
for k = 1 : 2
  rin = it_mean(:, :, k);
  rsp = sp_mean(:, :, k);

  rin = rin ./ (nopt.sNF(:) * ones(1, 9));
  rsp = rsp ./ (nopt.sNF(:) * ones(1, 9));

  % correction parameters
  a2 = nopt.a2;   % a2 correction weights
  ca = 8192/2.5;  % analog to digital gain
  cm = nopt.cm;   % modulation efficiency
  cp = nopt.cp;   % PGA gain
  Vinst = nopt.Vinst;

  % get the DC level
  Vdc = Vinst + 2*sum(abs(rin - rsp))' ./ (cm .* cp * ca * inst.npts * inst.df);

  % combined gain factor 
  cg = cm .* cp * ca * inst.df / 2;

  % divide by gain factors
  rin = rin ./ (ones(inst.npts, 1) * cg');
  rsp = rsp ./ (ones(inst.npts, 1) * cg');

  rdif = rin - rsp;
  rcor = zeros(m, 9);

  % apply the SA correction
  for fi = 1 : 9;
    rcor(:, fi) = Sinv(:,:,fi) * rdif(:,fi);
  end

  % divide out by Planck function
  r280K = bt2rad(inst.freq, 280) * ones(1,9);
  rcor = rcor ./ r280K;

  % normalize the corrected difference
  rcor = rcor ./ max(abs(rcor));

  figure(1); clf
  set(gcf, 'DefaultAxesColorOrder', fovcolors);
  plot(inst.freq, abs(rcor))
% axis([600, 1160, 0, 1.1])
  axis([2100, 2600, 0, 1.1])
  title([opts.cvers, ' ', inst.band, ' optical responsivity'])
  legend(fovnames, 'location', 'south')
  xlabel('wavenumber')
  ylabel('weight')
  grid on

% d2 = load('/home/motteler/cris/cris_test/resp_filt.mat');
% hold on
% plot(d2.freq_lw, d2.filt_lw / max(d2.filt_lw), 'linewidth', 2)
% axis([600, 1160, 0, 1.1])
% hold off

% saveas(gcf, 'IT_minus_SP_SA_norm', 'png')

  keyboard

% rrel =  abs(rin - rsp) ./ abs(rsp);
% plot(inst.freq, rrel(:, [1 3 7 9]))
% plot(inst.freq, rrel);
% axis([650,1100, 1, 4])

end % sweep direction loop

