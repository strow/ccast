%
% NAME
%   calmain4 - main calibration procedure
%
% SYNOPSIS
%   [rcal, vcal, msc] = ...
%      calmain4(inst, rcnt, stime, avgIT, avgSP, sci, eng, opts);
%
% INPUTS
%   inst    - instrument params struct
%   rcnt    - nchan x 9 x 34 x nscan, rad counts
%   stime   - 34 x nscan, rad count times
%   avgIT   - nchan x 9 x 2 x nscan, moving avg IT rad count
%   avgSP   - nchan x 9 x 2 x nscan, moving avg SP rad count
%   sci     - struct array, data from 8-sec science packets
%   eng     - struct, most recent engineering packet
%   opts    - for now, everything else
%
% OUTPUTS
%   rcal    - nchan x 9 x 30 x nscan, calibrated radiance
%   vcal    - nchan x 1 frequency grid
%   msc     - optional returned parameters
%
% DISCUSSION
%
%   general purpose version derived from hi-res calmainX, the
%   dcast version of calmain2, and the bcast calmain3
%
%   this version of calmain implements the calibration equation as
%   rICT*(SA-1*(ES-SP)/(ICT-SP).  
%
%   we compute rICT, the expected ICT radiance, at the sensor grid
%   and multiply after the SA-1 transform taking all the FOVs to the
%   sensor grid
%
% AUTHOR
%   H. Motteler, 26 Apr 2012

function [rcal, vcal, msc] = ...
     calmain4(inst, user, rcnt, stime, avgIT, avgSP, sci, eng, opts)

% load parameters for nlc()
control = load(opts.DClevel_file);
control.NF = load(opts.cris_NF_file);
control.NF = control.NF.NF;

% get key dimensions
[nchan, n, k, nscan] = size(rcnt);

% initialize the output array
rcal = ones(nchan, 9, 30, nscan) * NaN;

% initialize working arrays
es_nlc = ones(nchan, 1) * NaN;
sp_nlc = ones(nchan, 2) * NaN;
it_nlc = ones(nchan, 2) * NaN;

% local names for some sensor grid params
vinst = inst.freq;
wlaser = inst.wlaser;
band = upper(inst.band);

% local names for some user grid params
uv1 = user.v1;   % final passband lower bound
uv2 = user.v2;   % final passband upper bound
udv = user.dv;   % user-grid dv (for interpolation)

% set the pre-transform passband.  This is applied to the 
% ratio (ES-SP)/(ICT-SP) before applying the SA-1 matrix.
% iv1 = vinst(1); iv2 = vinst(end);
% pv1 = max(iv1, iv1 + (uv1 - iv1) / 2);
% pv2 = min(iv2, iv2 - (iv2 - uv2) / 2);
pv1 = uv1;
pv2 = uv2;

% get the SRF tabulation file for this band
switch band
  case 'LW'
    sfile = opts.sfileLW;
  case 'MW'
    sfile = opts.sfileMW;
  case 'SW'
    sfile = opts.sfileSW;
end

% get SRF matrix for the current wlaser
Smat = getSRFwl(wlaser, sfile);

% take the inverse after interpolation
Sinv = zeros(nchan, nchan, 9);
for i = 1 : 9
  Sinv(:,:,i) = inv(squeeze(Smat(:,:,i)));
end

for si = 1 : nscan   % loop on scans
 
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
  B = ICTradModel(band, vinst, T_ICT, ...
                  sci(ix), eng.ICT_Param, ...
                  1, NaN, 1, NaN);

  % copy rIT across 30 columns
  rIT = B.total(:) * ones(1, 30);

  for iFov = 1 : 9  % loop on FOVs
    for k = 1 : 2   % loop on sweep directions
 
      % do the ICT and space look nonlinearity corrections
      [sp_nlc(:, k), extra] = nlc(band, iFov, vinst, ...
                                  avgSP(:, iFov, k, si), ...
                                  avgSP(:, iFov, k, si), ...
                                  eng.PGA_Gain, control);   

      [it_nlc(:, k), extra] = nlc(band, iFov, vinst, ...
                                  avgIT(:, iFov, k, si), ...
                                  avgSP(:, iFov, k, si), ...
                                  eng.PGA_Gain, control);   
    end    

    for iES = 1 : 30  % loop on ES

      % match ES and cal sweep directions.  The ES and cal indices
      % have opposite parity for real instrument (vs 2010 test) data
%     k = 2 - mod(iES, 2);  % same parity for 2010 proxy data
      k = mod(iES, 2) + 1;  % opposite parity for all real data

      % do the ES nonlinearity correction
      [es_nlc, extra] = nlc(band, iFov, vinst, ...
                            rcnt(:, iFov, iES, si), ...
                            avgSP(:, iFov, k, si), ...
                            eng.PGA_Gain, control);   

      % calculate (ES-SP)/(ICT-SP), accounting for sweep direction
      rcal(:, iFov, iES, si) = ...
              (es_nlc - sp_nlc(:,k)) ./ (it_nlc(:,k) - sp_nlc(:,k));

    end     % loop on ES
  end       % loop on FOVs

  % loop on FOVs, apply the bandpass and SA-1 transforms
  % note we are vectorizing in chunks of size nchan x 30 here
  for fi = 1 : 9

    rtmp = squeeze(real(rcal(:,fi,:,si)));  

    rtmp = bandpass(vinst, rtmp, pv1, pv2);

    rtmp = rIT .* (Sinv(:,:,fi) * rtmp);

    rtmp = bandpass(vinst, rtmp, pv1, pv2);

    [rtmp, vcal] = finterp(rtmp, vinst, udv);

    rtmp = bandpass(vcal, rtmp, uv1, uv2);

    % save the current nchan x 30 chunk
    [n,k] = size(rtmp);
    n = min(n, nchan);
    rcal(1:n,fi,:,si) = rtmp(1:n, :);

  end      % loop on FOVs
end        % loop on scans

% trim to interpolated channel set
vcal = vcal(1:n);
rcal = rcal(1:n, :, :, :);
msc = struct;

