%
% NAME
%   calmain1 - main calibration procedure
%
% SYNOPSIS
%   [rcal, vcal, msc] = ...
%      calmain2(band, vinst, rcnt, stime, avgIT, avgSP, sci, eng, opt);
%
% INPUTS
%   band    - 'lw', 'mw', or 'sw'
%   vinst   - nchan x 1 frequency grid, 
%   rcnt    - nchan x 9 x 34 x nscan, rad counts
%   stime   - 34 x nscan, rad count times
%   avgIT   - nchan x 9 x 2 x nscan, moving avg IT rad count
%   avgSP   - nchan x 9 x 2 x nscan, moving avg SP rad count
%   sci     - struct array, data from 8-sec science packets
%   eng     - struct, most recent engineering packet
%   opt     - optional input parameters
%
% OUTPUTS
%   rcal    - nchan x 9 x 30 x nscan, calibrated radiance
%   vcal    - nchan x 1 frequency grid
%   msc     - optional returned parameters
%
% DISCUSSION
%
%   this version of calmain implements the calibration equation as
%   rICT*(SA-1*(ES-SP)/(ICT-SP).  It is modified to work with high
%   res spectra.
%

function [rcal, vcal, msc] = ...
     calmain1(band, vinst, rcnt, stime, avgIT, avgSP, sci, eng, opt)

% space temperature
% spt = 2.7279;

% get key dimensions
[nchan, n, k, nscan] = size(rcnt);

% --------------------
% set up the SA matrix
% --------------------

% *** TEMPORARY *** set SRF file and band edges
switch band
  case 'lw'
    sfile = 'hiresX/SRF_v1_LW.mat';
    uv1 = 650; uv2 = 1095; udv = 0.625;
  case 'mw'
    sfile = 'hiresX/SRF_v1_MW.mat';
    uv1 = 1210; uv2 = 1750; udv = 0.625;
  case 'sw'
    sfile = 'hiresX/SRF_v1_SW.mat';
    uv1 = 2155; uv2 = 2550; udv = 0.625;
end

% set the pre-transform passband.  This is applied to the ratio
% (ES-SP)/(ICT-SP) before applying the SA-1 matrix.
iv1 = vinst(1); iv2 = vinst(end);
% pv1 = max(iv1, iv1 + (uv1 - iv1) / 2);
% pv2 = min(iv2, iv2 - (iv2 - uv2) / 2);
pv1 = uv1;
pv2 = uv2;

% get SA-1 for the current wlaser
Smat = getSRFwl(opt.wlaser, sfile);

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

    rtmp = bandpass(rtmp, vinst, pv1, pv2);

    rtmp = rIT .* (Sinv(:,:,fi) * rtmp);

    rtmp = bandpass(rtmp, vinst, pv1, pv2);

    [rtmp, vcal] = finterp(rtmp, vinst, udv);

    rtmp = bandpass(rtmp, vcal, uv1, uv2);

    % this is temporary, eventually we should trim rcal to match 
    % the final bandpass
    [n,k] = size(rtmp);
    n = min(n, nchan);
    rcal(1:n,fi,:,si) = rtmp(1:n, :);

  end
end

% vcal = vinst;
vcal = vcal(1:n);
msc = struct;

