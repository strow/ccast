%
% NAME
%   rec_var -- recursive variance
%
% SYNOPSIS
%   [s2, n2] = rec_var(m, s1, n1, x)
%
% INPUTS
%   m    - mean of the full, final sequence
%   s1   - std^2 of x(1), x(2), ..., x(n1) wrt m
%   n1   - number of values in s1
%   x    - next value for the std
%   
% OUTPUTS
%   s2   - std^2 of x(1), x(2),..., x(n1), x(n1+1) wrt m
%   n2   - number of values in s2, always equal to n1+1
%
% EXAMPLE
%   nrow = 100;
%   ncol = 200;
%   x = randn(nrow, ncol)*100;
%   m = zeros(nrow,1);
%   n = 0;
%
%   for i = 1 : ncol
%     [m, n] =  rec_mean(m, n, x(:,i));
%   end
% 
%   q = mean(x, 2);
%   r = rms(m - q) / rms(q)
%   isequal(n, ncol)
% 
% AUTHOR
%  H. Motteler, 6 Nov 2012
%

function [s2, n2] = rec_var(m, s1, n1, x)

m = m(:);
x = x(:);
s1 = s1(:);

if length(m) ~= length(s1) || length(s1) ~= length(x)
  error('input vector lengths must match')
end

s2 = s1 .* (n1/(n1+1)) + (x - m).^2 ./ (n1+1);
n2 = n1 + 1;

% recursive mean
% m2 = m1 .* (n1/(n1+1)) + x ./ (n1+1);
% n2 = n1 + 1;

