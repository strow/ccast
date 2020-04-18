%
% NAME
%   calmain_c7 - ccast algorithm 1 with resampling
%
% SYNOPSIS
%   [rcal, vcal, nedn] = ...
%     calmain_c7(inst, user, rcnt, avgIT, avgSP, sci, eng, geo, opts);
%
% INPUTS
%   inst    - instrument params struct
%   user    - user grid params struct
%   rcnt    - n x 9 x 34 x nscan, rad counts
%   avgIT   - n x 9 x 2 x nscan, moving avg IT rad count
%   avgSP   - n x 9 x 2 x nscan, moving avg SP rad count
%   sci     - struct array, data from 8-sec science packets
%   eng     - struct, most recent engineering packet
%   geo     - struct, GCRSO geo fields from ccast L1a
%   opts    - for now, everything else
%
% OUTPUTS
%   rcal    - m x 9 x 30 x nscan, calibrated radiance
%   vcal    - m x 1 frequency grid
%   nedn    - m x 2 NEdN estimates
%
% DISCUSSION
%   see ccast/doc/ccast_eqns for an overview of different forms of
%   the calibration equations.
%
% AUTHOR
%   H. Motteler, 26 Apr 2012
%

function [rcal, vcal, nedn] = ...
  calmain_c7(inst, user, rcnt, avgIT, avgSP, sci, eng, geo, opts)

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

% get processing filter specs
pL = inst.pL; pH = inst.pH; rL = inst.rL; rH = inst.rH;

% build the resampling matrix
[R, vcal] = resamp(inst, user, opts.resamp);

%---------------
% loop on scans
%---------------

for si = 1 : nscan 
 
  % check that this row has some ES's 
  if isnan(max(geo.FORTime(1:30, si)))
    continue
  end

  % get index of the closest sci record
  dt = abs(max(geo.FORTime(:, si)) - tai2iet(utc2tai([sci.time]/1000)));
  ic = find(dt == min(dt));

  % sci scan time as TAI, for ICTradModel
  tscan = utc2tai(sci(ic).time/1000);

  % get ICT temperature
  T_ICT = (sci(ic).T_PRT1 + sci(ic).T_PRT2) / 2;

  % get expected ICT radiance at the sensor grid
  B = ICTradModel(inst.band, inst.freq, T_ICT, sci(ic), eng.ICT_Param, tscan, opts);

  % copy rIT across 30 columns
  rIT = B.total(:) * ones(1, 30);

  %-------------------------
  % earth scene calibration
  %-------------------------

  % loop on sweep direction
  for k = 1 : 2
    j = mod(k, 2) + 1; % SP and IT index

    % do the SP and IT nonlinearity corrections
    sp_nlc(:,:,j) = nlc_vec(inst, avgSP(:,:,j,si), avgSP(:,:,j,si), nopt);
    it_nlc(:,:,j) = nlc_vec(inst, avgIT(:,:,j,si), avgSP(:,:,j,si), nopt);

    % save the IT - SP difference
    it_sp(:, :, k) = it_nlc(:,:,j) - sp_nlc(:,:,j);
  end

  % loop on earth scenes
  for iES = 1 : 30
    j = mod(iES, 2) + 1; % SP and IT index

    % do the ES nonlinearity correction
    es_nlc = nlc_vec(inst, rcnt(:, :, iES, si), avgSP(:, :, j, si), nopt);   

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
    t3 = bandpass(inst.freq, t3, pL, pH, rL, rH);
    t3 = Sinv(:,:,fi) * t3;
    t3 = bandpass(inst.freq, t3, pL, pH, rL, rH);
    t3 = rIT .* t3;
    t3 = R * t3;

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
    rtmp = R * rtmp;

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
% nedn = nanstd(real(rICT), 0, 4);

% apply principal component filter to NEdN 
% nedn = nedn_filt(user, opts.nedn_filt, vcal, nedn);

% unapodized NEdN
nedn1 = nanstd(real(rICT(:,:,:)), 0, 3);  

% apodized NEdN
ntmp = real(rICT(:,:));
ntmp = hamm_app(ntmp);
ntmp = reshape(ntmp, mchan, 9, 2*nscan);
nedn2 = nanstd(ntmp, 0, 3);

% return both without filtering
nedn = cat(3, nedn1, nedn2);
