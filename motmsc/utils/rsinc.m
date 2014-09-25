%
% NAME
%   rsinc -- normalized regular sinc
%
% SYNOPSIS
%   y = rsinc(x)
%
% DISCUSSION
%   same as matlab sinc, used for comparison with psinc
%

function y = rsinc(x)

x = x * pi;

y = sin(x) ./ x;

y(find(x==0)) = 1;

