%
% NAME
%   mat2utc - take Matlab date numbers to UTC 58
%
% SYNOPSIS
%   utc = mat2utc(dnum)
%
% INPUT
%   dnum  - Matlab serial date numbers
%
% OUTPUT
%   utc   - UTC seconds since 1 Jan 1958
%

function utc = mat2utc(dnum)

utc = (dnum - datenum('1 Jan 1958')) * 86400;

