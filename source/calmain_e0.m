%
% NAME
%   calmain - main calibration procedure
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

% initialize the output array
rcal = ones(nchan, 9, 30, nscan) * NaN;

% initialize working arrays
es_nlc = ones(nchan, 9) * NaN;
sp_nlc = ones(nchan, 9, 2) * NaN;
it_nlc = ones(nchan, 9, 2) * NaN;
es_sp = ones(nchan, 9, 30) * NaN;
it_sp = ones(nchan, 9, 2) * NaN;

% NEdN setup
rICT = ones(nchan, 9, 2, nscan) * NaN;
sp_all = rcnt(:, :, 31:32, :);
it_all = rcnt(:, :, 33:34, :);
sp_mean = nanmean(sp_all, 4);
it_mean = nanmean(it_all, 4);

% select band-specific options
switch inst.band
  case 'LW', sfile = opts.LW_sfile;
  case 'MW', sfile = opts.MW_sfile;
  case 'SW', sfile = opts.SW_sfile;
end

% select band-specific options
switch inst.band
  case 'LW', v1p = [0.32 0.16 0.32 0.16 0.02 0.16 0.32 0.16 0.32];
  case 'MW', v1p = zeros(1, 9);
  case 'SW', v1p = zeros(1, 9);
end

% get the SA inverse matrix
Sinv = getSAinv(sfile, inst);

%---------------
% loop on scans
%---------------

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

  % copy rIT across 30 columns
  rIT = B.total(:) * ones(1, 30);

  %-------------------------
  % earth scene calibration
  %-------------------------

  % loop on sweep direction
  for k = 1 : 2
    j = mod(k, 2) + 1; % SP and IT index

    % do the SP and IT nonlinearity corrections
    sp_nlc(:,:,j) = nlc_vec(inst, avgSP(:,:,j,si), avgSP(:,:,j,si), eng);
    it_nlc(:,:,j) = nlc_vec(inst, avgIT(:,:,j,si), avgSP(:,:,j,si), eng);

    % save the IT - SP difference
    it_sp(:, :, k) = it_nlc(:,:,j) - sp_nlc(:,:,j);
  end

  % loop on earth scenes
  for iES = 1 : 30
    j = mod(iES, 2) + 1; % SP and IT index

    % do the ES nonlinearity correction
    es_nlc = nlc_vec(inst, rcnt(:, :, iES, si), avgSP(:, :, j, si), eng);   

    % save the ES - SP difference
    es_sp(:, :, iES) = es_nlc - sp_nlc(:, :, j);
  end

  % loop on FOVs
  for fi = 1 : 9

    % apply the bandpass and SA-1 transform
    t3 = squeeze(es_sp(:, fi, :));
    t4 = squeeze(it_sp(:, fi, :));
    t4 = reshape(t4(:) * ones(1, 15), nchan, 30);
    t3 = t3 ./ t4;
    t3 = bandpass(inst.freq, t3, user.v1 - v1p(fi), user.v2, user.vr);
    t3 = Sinv(:,:,fi) * t3;
    t3 = bandpass(inst.freq, t3, user.v1, user.v2, user.vr);
    t3 = rIT .* t3;
    [t3, vcal] = finterp(t3, inst.freq, user.dv);

    % save the current nchan x 30 chunk
    [n, k] = size(t3);
    mchan = min(n, nchan);
    rcal(1:mchan, fi, :, si) = t3(1:mchan, :);

  end

  %---------------------------
  % IT calibration (for NEdN)
  %---------------------------

  % calculate (IT(i) - SP) / (IT - SP) for both sweep directions
  rICT(:,:,:,si) = (it_all(:,:,:,si) - sp_mean) ./ (it_mean - sp_mean);

  % loop on FOVs
  for fi = 1 : 9

    % apply the bandpass and SA-1 transforms
    rtmp = squeeze(rICT(:, fi, :, si));
    rtmp = bandpass(inst.freq, rtmp, user.v1, user.v2, user.vr);
    rtmp = rIT(:, 1:2) .* (Sinv(:,:,fi) * rtmp);
    rtmp = bandpass(inst.freq, rtmp, user.v1, user.v2, user.vr);
    [rtmp, it_vcal] = finterp(rtmp, inst.freq, user.dv);

    % save the current nchan x 2 chunk
    rICT(1:mchan, fi, :, si) = rtmp(1:mchan, :);

  end
end

%-----------
% finish up
%-----------

% trim outputs to interpolated channel set
vcal = vcal(1:mchan);
rcal = rcal(1:mchan, :, :, :);
rICT = rICT(1:mchan, :, :, :);

% NEdN is the standard deviation of rICT
nedn = nanstd(real(rICT), 0, 4);

% apply principal component filter to NEdN 
nedn = nedn_filt(user, opts.nedn_filt, vcal, nedn);

