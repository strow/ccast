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

% get the spectral space numeric filter
inst.sNF = specNF(inst, opts.specNF_file);

% get key dimensions
[nchan, n, k, nscan] = size(rcnt);

% initialize the output array
rcal = ones(nchan, 9, 30, nscan) * NaN;

% initialize working arrays
es_nlc = ones(nchan, 9) * NaN;
sp_nlc = ones(nchan, 9, 2) * NaN;
it_nlc = ones(nchan, 9, 2) * NaN;

% select band-specific options
switch inst.band
  case 'LW', sfile = opts.LW_sfile;
  case 'MW', sfile = opts.MW_sfile;
  case 'SW', sfile = opts.SW_sfile;
end

% get SRF matrix for the current wlaser
Smat = getSRFwl(inst.wlaser, sfile);

% take the inverse after interpolation
Sinv = zeros(nchan, nchan, 9);
for i = 1 : 9
  Sinv(:,:,i) = inv(squeeze(Smat(:,:,i)));
end

% loop on scans
for si = 1 : nscan 
 
  % check that this row has some ES's
  if isnan(max(stime(1:30, si)))
    continue
  end

  % get index of the closest sci record, 
  dt = abs(max(stime(:, si)) - [sci.time]);
  ix = find(dt == min(dt));

  % compute ICT temperature
  T_ICT = (sci(ix).T_PRT1 + sci(ix).T_PRT2) / 2;

  % Compute predicted radiance from ICT
  B = ICTradModel(inst.band, inst.freq, T_ICT, sci(ix), eng.ICT_Param, ...
                  1, NaN, 1, NaN);

  % copy rIT across 30 columns
  rIT = B.total(:) * ones(1, 30);

  % loop on sweep directions
  for k = 1 : 2

    % do the SP and IT nonlinearity corrections
    sp_nlc(:, :, k) = nlc_vec(inst, avgSP(:, :, k, si), ...
                                    avgSP(:, :, k, si), eng);

    it_nlc(:, :, k) = nlc_vec(inst, avgIT(:, :, k, si), ...
                                    avgSP(:, :, k, si), eng);
  end

  % loop on earth-scenes
  for iES = 1 : 30

    % the ES and calibration indices have opposite parity
    k = mod(iES, 2) + 1;

    % do the ES nonlinearity correction
    es_nlc = nlc_vec(inst, rcnt(:, :, iES, si), ...
                          avgSP(:, :,  k,  si), eng);   

    % calculate (ES-SP)/(ICT-SP), accounting for sweep direction
    rcal(:, :, iES, si) = ...
      (es_nlc - sp_nlc(:,:,k)) ./ (it_nlc(:,:,k) - sp_nlc(:,:,k));

  end

  % loop on FOVs, apply the bandpass and SA-1 transforms
  % note we are vectorizing in chunks of size nchan x 30 here
  for fi = 1 : 9

    rtmp = squeeze(rcal(:,fi,:,si));  

    rtmp = bandpass(inst.freq, rtmp, user.v1, user.v2, user.vr);

    rtmp = rIT .* (Sinv(:,:,fi) * rtmp);

    rtmp = bandpass(inst.freq, rtmp, user.v1, user.v2, user.vr);

    [rtmp, vcal] = finterp(rtmp, inst.freq, user.dv);

%   rtmp = bandpass(vcal, rtmp, user.v1, user.v2, user.vr);

    % save the current nchan x 30 chunk
    [n,k] = size(rtmp);
    mchan = min(n, nchan);
    rcal(1:mchan, fi, :, si) = rtmp(1:mchan, :);

  end      % loop on FOVs
end        % loop on scans

% trim to interpolated channel set
vcal = vcal(1:mchan);
rcal = rcal(1:mchan, :, :, :);

%----------------
% calculate NEdN
%----------------
it_cal = zeros(nchan, 9, 2, nscan);
sp_nlc = zeros(nchan, 9, 2);
it_nlc = zeros(nchan, 9, 2);

sp_all = rcnt(:, :, 31:32, :);
it_all = rcnt(:, :, 33:34, :);

sp_mean = nanmean(sp_all, 4);
it_mean = nanmean(it_all, 4);

% loop on sweep direction 
for k = 1 : 2
  % do nonlinearity corrections for the SP and IT means
  sp_nlc(:,:,k) = nlc_vec(inst, sp_mean(:,:,k), sp_mean(:,:,k), eng);  
  it_nlc(:,:,k) = nlc_vec(inst, it_mean(:,:,k), sp_mean(:,:,k), eng);  
end

% copy rIT across 2 columns
rIT =  B.total(:) * ones(1, 2);

% loop on scans
for si = 1 : nscan

  % loop on sweep direction 
  for k = 1 : 2
    % do nonlinearity correction for the individual IT looks
    it_cal(:,:,k,si) = nlc_vec(inst, it_all(:,:,k,si), sp_mean(:,:,k), eng); 
  end

  % calculate (IT(i) - SP) / (IT - SP) for both sweep directions
  it_cal(:,:,:,si) = (it_cal(:,:,:,si) - sp_nlc) ./ (it_nlc - sp_nlc);

  % loop on FOVs, apply the bandpass and SA-1 transforms
  for fi = 1 : 9

    it_tmp = squeeze(it_cal(:, fi, :, si));
    
    it_tmp = bandpass(inst.freq, it_tmp, user.v1, user.v2, user.vr);

    it_tmp = rIT .* (Sinv(:,:,fi) * it_tmp);

    it_tmp = bandpass(inst.freq, it_tmp, user.v1, user.v2, user.vr);

    [it_tmp, vcal] = finterp(it_tmp, inst.freq, user.dv);

%   it_tmp = bandpass(vcal, it_tmp, user.v1, user.v2, user.vr);

    % save the current nchan x 2 chunk
    it_cal(1:mchan, fi, :, si) = it_tmp(1:mchan, :);
  end
end

% trim to interpolated channel set
it_cal = it_cal(1:mchan, :, :, :);

% take the standard deviation
nedn = nanstd(it_cal, 0, 4);

% plot(vcal, squeeze(nedn(:, :, 2)))
% axis([user.v1, user.v2, 0, 1.2])    % LW
% axis([user.v1, user.v2, 0, 0.1])    % MW
% axis([user.v1, user.v2, 0, 0.02])   % SW

