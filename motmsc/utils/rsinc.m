%
% NAME
%   rsinc -- non-normalized sinc
%
% SYNOPSIS
%   y = rsinc(x)
%

function y = rsinc(x)

y = sin(x) ./ x;

y(find(x==0)) = 1;

