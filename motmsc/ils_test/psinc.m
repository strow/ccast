%
% NAME
%   psinc -- normalized periodic sinc
%
% SYNOPSIS
%   y = psinc(x, n)
%

function y = psinc(x, n)

x = x * pi;

y = sin(x) ./ (n * sin(x/n));

y(find(x==0)) = 1;

