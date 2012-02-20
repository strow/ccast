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
%   rcal    - nchan x 9 x 34 x nscan, calibrated radiance
%   vcal    - nchan x 1 frequency grid
%   msc     - optional returned parameters
%
% DISCUSSION
%
%   calmain1 is a prototype with the old basic rad cal code
%

function [rcal, vcal, msc] = ...
     calmain1(band, vinst, rcnt, stime, avgIT, avgSP, sci, eng, opt);

% space temperature
spt = 2.7279;

% get key dimensions
[nchan, n, k, nscan] = size(rcnt);

% initialize output arrays
rcal = ones(nchan, 9, 30, nscan) * NaN;

for i = 1 : nscan   % loop on scans
 
  % check that this row has some ES's
  if isnan(max(stime(1:30, i)))
    continue
  end

  % get index of the closest sci record, 
  dt = abs(max(stime(:, i)) - [sci.time]);
  ix = find(dt == min(dt));

  % get black-body spectra for IT and SP.  Needs emissivity factor.
  % for now, treat all FOVs as identical
  ict = (sci(ix).T_PRT1 + sci(ix).T_PRT2) / 2;
  rIT = bt2rad(vinst, ict) * ones(1,9);
  rSP = bt2rad(vinst, spt) * ones(1,9);

  for j  = 1 : 30   % loop on ES

    rcal(:,:,j,i) = rIT - (avgIT(:,:,1,i) - rcnt(:,:,j,i)) .* ...
                    (rIT - rSP) ./ (avgIT(:,:,1,i) - avgSP(:,:,1,i));
  end
end

vcal = vinst;
msc = struct;

