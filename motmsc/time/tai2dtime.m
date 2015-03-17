%
% NAME
%   tai2dtime - take TAI 58 to Matlab datetime
%
% SYNOPSIS
%   dtime = tai2dtime(tai);
%
% INPUT
%   tai   - TAI time, seconds from 1 Jan 1958
%
% OUTPUT
%   dtime - a Matlab datetime object
%
% DISCUSSION
%   dependds on undocumented features of datetime
%
% AUTHOR
%   H. Motteler, 15 Mar 2015
%

function dtime = tai2dtime(tai);

% TAI epoch base with Matlab UTC leap seconds
d58 = datetime('1958-01-01T00:00:00.000Z','timezone','UTCLeapSeconds');

% convert regular datetime to UTC leap seconds
tmp = dtime;
tmp.TimeZone = 'UTCLeapSeconds';
tmp.Year   = dtime.Year;
tmp.Month  = dtime.Month;
tmp.Day    = dtime.Day;
tmp.Hour   = dtime.Hour;
tmp.Minute = dtime.Minute;
tmp.Second = dtime.Second;

% Matlab UTC leap seconds are 10 seconds behind
tai = seconds(tmp - d58) + 10;

