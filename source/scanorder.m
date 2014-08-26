%
% NAME
%   scanorder - use FOR values to group data into scans
%
% SYNOPSIS
%   [swLW, swMW, swSW, swTime] = ...
%         scanorder(rcLW, rcMW, rcSW, igmTime, igmFOR, igmSDR, rid);
% INPUTS
%   rcLW    - nchan x 9 x nobs, LW rad counts
%   rcMW    - nchan x 9 x nobs, MW rad counts
%   rcSW    - nchan x 9 x nobs, SW rad counts
%   igmTime - nobs x 1, igm/rad count times
%   igmFOR  - nobs x 1, igm/rad count FORs
%   igmSDR  - nobs x 1, igm/rad count sweep direction
%   rid     - file date and time ID
%
% OUTPUTS
%   swLW   - nchan x 9 x 34 x nscan, LW rad counts
%   swMW   - nchan x 9 x 34 x nscan, MW rad counts
%   swSW   - nchan x 9 x 34 x nscan, SW rad counts
%   swTime - 34 x nscan, rad count times
%
% DISCUSSION
%
% Move obs to an nchan x 9 x 34 x nscan array, with gaps filled
% with NaNs.  In the 3rd dim, indices 1:30 are ES data, 31:32 SP,
% and 33:34 IT.  If the data from checkRDR has no time or FOR gaps
% anywhere and started with FOR 1, this would just be a reshape.
%
% The data (in column order) is ordered by time.  ES FORs are the
% same as their indices. Some consistency checks are done with the
% FOR and time sequences
%
% AUTHOR
%   H. Motteler, 30 Oct 2011
%

function [swLW, swMW, swSW, swTime] = ...
          scanorder(rcLW, rcMW, rcSW, igmTime, igmFOR, igmSDR, rid);

[nchLW, m, n] = size(rcLW);
[nchMW, m, n] = size(rcMW);
[nchSW, m, n] = size(rcSW);

% get obs count
nobs = length(igmTime);
obsind = (1:nobs)';

% --------------------
% get swath boundaries
% --------------------

% build a list of swath start and stop points as obs indices.
% Look at [obsind, t1, t3, t4] to see how this works.

t1 = igmFOR;         % FOR values for all obs
t1(t1 == 0) = 32;    % sub 32 for 0, so SP = 31, IT = 32
t2 = diff(t1) < 0;   % FOR decrease implies swath start
t3 = [0<1; t2];      % swath start flags
t4 = [t2; 0<1];      % swath end flags

% "swath" is an array of swath start and end points
swath = [obsind(t3), obsind(t4)];
[nscan, nx] = size(swath);

% initialize output arrays
swLW = ones(nchLW, 9, 34, nscan) * NaN;
swMW = ones(nchMW, 9, 34, nscan) * NaN;
swSW = ones(nchSW, 9, 34, nscan) * NaN;
swFOR = ones(34, nscan) * NaN;
swSDR = ones(34, nscan) * NaN;
swTime = ones(34, nscan) * NaN;

% ----------------------------
% loop on swaths, reshape data
% ----------------------------

for si = 1 : nscan

  % get indices for current swath
  ix = swath(si,1) : swath(si,2);

  iES = ix((1 <= igmFOR(ix)) & (igmFOR(ix) <= 30));
  iIT = ix(igmFOR(ix) == 0);
  iSP = ix(igmFOR(ix) == 31);

  % assign ES data for the swath by FOR indices
  itmp = igmFOR(iES);
  swLW(:, :, itmp, si) = rcLW(:, :, iES);
  swMW(:, :, itmp, si) = rcMW(:, :, iES);
  swSW(:, :, itmp, si) = rcSW(:, :, iES);
  swFOR(itmp, si) = itmp;  
  swSDR(itmp, si) = igmSDR(iES);  
  swTime(itmp, si) = igmTime(iES);  

  % assign SP and IT data by sweep direction
  itmp = 31 + (1 - igmSDR(iSP));
  swLW(:, :, itmp, si) = rcLW(:, :, iSP);
  swMW(:, :, itmp, si) = rcMW(:, :, iSP);
  swSW(:, :, itmp, si) = rcSW(:, :, iSP);
  swFOR(itmp, si) = igmFOR(iSP);  
  swSDR(itmp, si) = igmSDR(iSP);  
  swTime(itmp, si) = igmTime(iSP);  

  itmp = 33 + (1 - igmSDR(iIT));
  swLW(:, :, itmp, si) = rcLW(:, :, iIT);
  swMW(:, :, itmp, si) = rcMW(:, :, iIT);
  swSW(:, :, itmp, si) = rcSW(:, :, iIT);
  swFOR(itmp, si) = igmFOR(iIT);  
  swSDR(itmp, si) = igmSDR(iIT);  
  swTime(itmp, si) = igmTime(iIT);  

  % check ES time steps
  tmpTime = swTime(1:30, si);
  tmpTime = tmpTime(~isnan(tmpTime));

  swTmax1 = max(diff(tmpTime));
  swTmin1 = min(diff(tmpTime));

  if swTmax1 > 210
    fprintf(1, 'scanorder: ES time step %.0f too big, scan %d file %s\n', ...
            swTmax1, si, rid);
  end
  if swTmin1 < 190
     fprintf(1, 'scanorder: ES time step %.1f too small, scan %d file %s\n', ...
             swTmin1, si, rid);
  end
end 

% ---------------------------------------------
% sanity checks of FOR, SDR, and time sequences
% ---------------------------------------------

tmpFOR = swFOR(~isnan(swFOR));
if ~isequal(igmFOR, tmpFOR)
   fprintf(1, 'scanorder: FOR sequence mismatch, file %s\n', rid);
end

tmpSDR = swSDR(~isnan(swSDR));
if ~isequal(igmSDR, tmpSDR)
   fprintf(1, 'scanorder: SDR sequence mismatch, file %s\n', rid);
%  keyboard
end

tmpTime = swTime(~isnan(swTime));
if ~isequal(igmTime, tmpTime)
   fprintf(1, 'scanorder: Time sequence mismatch, file %s\n', rid);
end
 
