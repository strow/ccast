%
% NAME
%   rec_mean -- recursive mean
%
% SYNOPSIS
%   [m2, n2] = rec_mean(m1, n1, x)
%
% INPUTS
%   m1   - the mean of x(1), x(2), ..., x(n1)
%   n1   - number of averaged values in m1
%   x    - next value for the mean
%   
% OUTPUTS
%   m2   - the mean of x(1), x(2),..., x(n1), x(n1+1)
%   n2   - number of values in m2, always equal to n1+1
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

function [m2, n2] = rec_mean(m1, n1, x)

x = x(:);
m1 = m1(:);

if length(x) ~= length(m1)
  error('input vector lengths must match')
end

m2 = m1 .* (n1/(n1+1)) + x ./ (n1+1);

n2 = n1 + 1;

