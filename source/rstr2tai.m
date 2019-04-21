%
% rstr2tai - translate NOAA filename time substring to TAI
%
% SYNOPSIS
%   [t1, t2] = rstr2tai(rstr)
%
% INPUTS
%   rstr - NOAA file name time substring
%
% OUTPUT
%   t1  - tai start time     
%   t2  - tai end time
%
% DISCUSSION
%   not vectorized
%
%   sample rstr date and times
%   d20170401_t0005487_e0013487
%   123456789012345678901234567
%   0        1         2
%
%   sample 2012 start time error
%   d20120511_t095058x_e0958567
%   123456789012345678901234567
%   0        1         2

function [t1, t2] = rstr2tai(rstr)

% work-around for 2012 geo filename bug with 'x' in tenths start
% time; probably OK because the pevious and following start time
% tenths position was always '9' or another 'x'
if rstr(18) == 'x'
  fprintf(1, 'rstr2tai: fixing bad start time %s\n', rstr)
  rstr(18) = '9';
end

[t,n,e] = sscanf(rstr, 'd%4d%2d%2d_t%2d%2d%3d_e%2d%2d%3d');

if isempty(t) || n ~= 9, error(e), end

t1 = dnum2tai(datenum([t(1),t(2),t(3),t(4),t(5),t(6)/10]));
t2 = dnum2tai(datenum([t(1),t(2),t(3),t(7),t(8),t(9)/10]));

% rstr
% datestr(tai2dnum(t1))
% datestr(tai2dnum(t2))

