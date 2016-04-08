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
t1 = ones(nchan, 9, 30) * NaN;
t2 = ones(nchan, 9, 2) * NaN;

% NEdN setup
rICT = ones(nchan, 9, 2, nscan) * NaN;
sp_all = rcnt(:, :, 31:32, :);
it_all = rcnt(:, :, 33:34, :);
sp_mean = nanmean(sp_all, 4);
it_mean = nanmean(it_all, 4);

% select band-specific options
switch inst.band
  case 'LW', sfile = opts.LW_sfile; bi = 1;
  case 'MW', sfile = opts.MW_sfile; bi = 2;
  case 'SW', sfile = opts.SW_sfile; bi = 3;
end

% NOAA processing filter
pfilt = f_atbd(bi, 1:inst.npts, 'noaa1');
pfilt2 = pfilt(:) * ones(1, 2);
pfilt30 = pfilt(:) * ones(1, 30);

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

  % get index of the closest sci record, 
  dt = abs(max(stime(:, si)) - [sci.time]);
  ix = find(dt == min(dt));
  sci_ICT = sci(ix);

  % compute ICT temperature
  T_ICT = (sci(ix).T_PRT1 + sci(ix).T_PRT2) / 2;

  % compute predicted radiance from ICT
  ugrid = cris_ugrid(user, 4);
  B = ICTradModel(inst.band, ugrid, T_ICT, sci_ICT, eng.ICT_Param, ...
                  1, NaN, 1, NaN);

  % copy rIT across 30 columns
  rIT = B.total(:) * ones(1, 30);

  %-------------------------
  % earth scene calibration
  %-------------------------

  % loop on sweep directions
  for k = 1 : 2

    % do the SP and IT nonlinearity corrections
    sp_nlc(:, :, k) = nlc_vec(inst, avgSP(:, :, k, si), ...
                                    avgSP(:, :, k, si), eng);

    it_nlc(:, :, k) = nlc_vec(inst, avgIT(:, :, k, si), ...
                                    avgSP(:, :, k, si), eng);
                                    
    % denominator of calibration ratio
    j = mod(k, 2) + 1;
    t2(:, :, j) = it_nlc(:, :, k) - sp_nlc(:, :, k);
  end

  % loop on earth scenes
  for iES = 1 : 30

    % the ES and calibration indices have opposite parity
    k = mod(iES, 2) + 1;

    % do the ES nonlinearity correction
    es_nlc = nlc_vec(inst, rcnt(:, :, iES, si), ...
                          avgSP(:, :,  k,  si), eng);   

    % numerator of calibration ratio
    t1(:, :, iES) = es_nlc - sp_nlc(:,:,k);
  end

  % loop on FOVs
  for fi = 1 : 9

    % process ICT - SP
    t4 = squeeze(t2(:, fi, :));
    [t4, a4] = pcorr2(t4);
%   t4 = bandpass(inst.freq, t4, user.v1, user.v2, user.vr);
    t4 = t4 .* pfilt2;
    t4 = Sinv(:,:,fi) * t4;
    [t4, vcal] = finterp(t4, inst.freq, user.dv);
    t4 = reshape(t4(:) * ones(1, 15), length(vcal), 30);
    a4 = reshape(a4(:) * ones(1, 15), nchan, 30);

    % process ES  - SP
    t3 = squeeze(t1(:, fi, :));
    t3 = pcapp2(t3, a4);
%   t3 = pcorr2(t3);
%   t3 = bandpass(inst.freq, t3, user.v1, user.v2, user.vr);
    t3 = t3 .* pfilt30;
    t3 = Sinv(:,:,fi) * t3;
    [t3, vcal] = finterp(t3, inst.freq, user.dv);

    t3 = t3 ./ t4;

    [ix, jx] = seq_match(ugrid, vcal);
    t3 = rIT(ix, :) .* t3(jx, :);
    vcal = vcal(jx);

    % save the current nchan x 30 chunk
    [n, k] = size(t3);
    mchan = min(n, nchan);
    rcal(1:mchan, fi, :, si) = t3(1:mchan, :);

  end

  %---------------------------
  % IT calibration (for NEdN)
  %---------------------------

  % compute predicted radiance from ICT
  B = ICTradModel(inst.band, inst.freq, T_ICT, sci_ICT, eng.ICT_Param, ...
                  1, NaN, 1, NaN);
  
  % copy rIT across 2 columns
  rIT = B.total(:) * ones(1, 2);

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

