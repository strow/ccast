%
% NAME
%   iet2mat - take IET to Matlab date numbers
%
% SYNOPSIS
%   dnum = iet2mat(iet)
%
% INPUT
%   iet   - IET time, microseconds from 1 Jan 1958
%
% OUTPUT
%   dnum  - Matlab serial date numbers
%

function dnum = iet2mat(iet)

dnum = tai2mat(iet * 1e-6);

