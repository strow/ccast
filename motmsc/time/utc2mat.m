%
% NAME
%   utc2mat - take UTC 58 to Matlab date numbers
%
% SYNOPSIS
%   dnum = utc2mat(utc)
%
% INPUT
%   utc   - UTC seconds since 1 Jan 1958
%
% OUTPUT
%   dnum  - Matlab serial date numbers
%

function dnum = utc2mat(utc)

dnum = datenum('1 Jan 1958') + utc / 86400;

