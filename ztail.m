%
% NAME
%   ztail -- find the nonzero end a vector or array
%
% SYNOPSIS
%   n = ztail(a);
%
% INPUT
%   any array
%
% OUTPUT
%   smallest n such that a(:) is all zeros past n

function n = ztail(a);

n = max(find(a(:) ~= 0));

