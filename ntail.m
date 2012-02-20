%
% NAME
%   ntail -- find the non-NaN end a vector or array
%
% SYNOPSIS
%   n = ntail(a);
%
% INPUT
%   any array
%
% OUTPUT
%   smallest n such that a(:) is all NaNs past n

function n = ntail(a);

n = max(find(~isnan(a(:))));

