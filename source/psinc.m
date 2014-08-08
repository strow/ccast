%
% NAME
%   psinc -- non-normalized periodic sinc
%
% SYNOPSIS
%   y = psinc(x, n)
%

function y = psinc(x, n)

y = sin(x) ./ (n * sin(x/n));

y(find(x==0)) = 1;

