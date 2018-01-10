%
% granule_t0 - granule t0 and index from ES 1
%
% SYNOPSIS
%   [t0, gi] = granule_t0(tES1, nscan)
%
% INPUT
%   tES1   - start time (ES 1) for some scan
%   nscan  - scans / granule
%
% OUTPUT
%   t0  - start time for first granule of the day
%   gi  - index of the granule that includes tES1 
%   
% DISCUSSION
%  granule_t0 finds the start time for the first complete scan of
%  the day, and also the index of the first granule that includes
%  tES1.  It works for two common cases: (1) files for a full day,
%  including a tail from the previous day, and (2) a sequence of
%  files, less than a full day, anytime during the day.
%
%  The outputs t0 and gi are inputs for fakeTime, which produces
%  a sequence of granule time frames aligned with t0 and starting
%  with granule ji
%
%  There may be too many sanity checks for code that is relatively
%  simple.
%

function [t0, gi] = granule_t0(tES1, nscan)

% get time for start of day
dvec = datevec(iet2dnum(tES1));
dvec(4:6) = [0 0 0];
tday = dnum2iet(datenum(dvec));

% if tES1 (first ES from the first file in a list) is within the
% last 8 minutes of the day assume it is a tail for the following
% day, increment the day, and increment tES1 in 8-second (1-scan)
% steps until it falls within the incremented day.
us_day = 8.64e10;   % microsec per day
us_8min = 4.8e8;    % microsec in 8 min
if tES1 > tday + us_day - us_8min
  dvec(3) = dvec(3) + 1;           % increment the day
  tday = dnum2iet(datenum(dvec));  % next day in IET 
  while tES1 < tday     % while tES not in day
    tES1 = tES1 + 8e6;  % increment tES1 in 8 sec steps
  end
end

% count scans back from tES1
k = 0;
while tday <= tES1 - k * 8e6 && k <= 10800
  k = k + 1;
end
k = k - 1;
if k < 0 || 10800 < k, error('bad scan count'), end
t0x = tES1 - k * 8e6;

% find scans back from tES1
k = floor((tES1 - tday) / 8e6);
t0 = tES1 - k * 8e6;

if t0x ~= t0, error('t0 check failed'), end

% find granules forward to tES1
gj = floor((tES1 - t0) / (nscan*8e6)) + 1;

% count granules forward to tES1
for gi = 1 : 10800/nscan
  tf = fakeTime(t0, nscan, gi, 0);
  if tf(1)-2e3 <= tES1 && tES1 <= tf(end)+2e3
    break
  end
end
if gi == 10800/nscan, error('gi count too large'), end

if gi ~= gj, error('gi check failed'), end

% display(datestr(iet2dnum(tES1)))
% display(datestr(iet2dnum(tday)))
% display(datestr(iet2dnum(t0)))

