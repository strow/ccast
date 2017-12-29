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
%   maybe too many sanity checks
%

function [t0, gi] = granule_t0(tES1, nscan)

% t0 ie IET start of day
dvec = datevec(iet2dnum(tES1));
dvec(4:6) = [0 0 0];
tday = dnum2iet(datenum(dvec));

% scans back from tES1
k = 0;
while tday <= tES1 - k * 8e6 && k <= 10800
  k = k + 1;
end
k = k - 1;
if k < 0 || 10800 < k, error('bad scan count'), end
t0x = tES1 - k * 8e6;

% scans back from tES1
k = floor((tES1 - tday) / 8e6);
t0 = tES1 - k * 8e6;

if t0x ~= t0, error('t0 check failed'), end

% granules forward to tES1
gj = floor((tES1 - t0) / (nscan*8e6)) + 1;

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

