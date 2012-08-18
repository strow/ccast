%
% NAME
%   calmain3 - main calibration procedure
%
% SYNOPSIS
%   [rcal, vcal, msc] = ...
%      calmain3(inst, rcnt, stime, avgIT, avgSP, sci, eng, opts);
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
%   general purpose version derived from hi-res calmainX, which
%   in turn was derived from calmain1
%
%   this version of calmain implements the calibration equation as
%   rICT*(SA-1*(ES-SP)/(ICT-SP).  it works with both regular and
%   hi-res data but doesn't include ICT radiance modeling or the
%   onlinearity correction.
%
% AUTHOR
%   H. Motteler, 20 Apr 2012

function [rcal, vcal, msc] = ...
     calmain3(inst, user, rcnt, stime, avgIT, avgSP, sci, eng, opts)

% space temperature
% spt = 2.7279;

% sensor grid params
vinst = inst.freq;
wlaser = inst.wlaser;
band = upper(inst.band);

% get SRF tabulation file
switch band
  case 'LW'
    sfile = opts.sfileLW;
  case 'MW'
    sfile = opts.sfileMW;
  case 'SW'
    sfile = opts.sfileSW;
end

% user grid specs
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

% get key dimensions
[nchan, n, k, nscan] = size(rcnt);

% get SRF matrix for the current wlaser
Smat = getSRFwl(wlaser, sfile);

% take the inverse after interpolation
Sinv = zeros(nchan, nchan, 9);
for i = 1 : 9
  Sinv(:,:,i) = inv(squeeze(Smat(:,:,i)));
end

% initialize the output array
rcal = ones(nchan, 9, 30, nscan) * NaN;

for si = 1 : nscan   % loop on scans
 
  % check that this row has some ES's
  if isnan(max(stime(1:30, si)))
    continue
  end

  % get index of the closest sci record, 
  dt = abs(max(stime(:, si)) - [sci.time]);
  ix = find(dt == min(dt));

  % get black-body spectra for IT and SP
  ict = (sci(ix).T_PRT1 + sci(ix).T_PRT2) / 2;
  rIT = bt2rad(vinst, ict);
% rSP = bt2rad(vinst, spt);

  % copy rIT across 30 columns
  rIT = rIT(:) * ones(1, 30);

  for j  = 1 : 30   % loop on ES

    % match sweep directions
%   if mod(j, 2) == 1, k = 1; else k = 2; end  % for 2010 proxy data
    if mod(j, 2) == 0, k = 1; else k = 2; end  % for all real data

    % take the ratio (ES-SP)/(ICT-SP)
    rcal(:,:,j,si) =  (rcnt(:,:,j,si) - avgSP(:,:,k,si)) ./ ...
                     (avgIT(:,:,k,si) - avgSP(:,:,k,si));
  end

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

  end
end

% trim to interpolated channel set
vcal = vcal(1:n);
rcal = rcal(1:n, :, :, :);
msc = struct;

