%
% NAME
%   rec_var -- recursive mean and variance
%
% SYNOPSIS
%   [u2, m2, n2] = rec_var(u1, m1, n1, x)
%
% INPUTS
%   u1   - current mean
%   m1   - current sum (x-u)^2
%   n1   - current count
%   x    - next data value
%   
% OUTPUTS
%   u2   - updated mean
%   m2   - updated sum (x-u)^2
%   n2   - updated count
%
%   variance = m2 / (n2 - 1)
%
% EXAMPLE
%   nrow = 100; ncol = 200;
%   x = randn(nrow, ncol) * 20;
%   u = zeros(nrow, 1); m = u; n = 0;
%   for i = 1 : ncol
%     [u, m, n] = rec_var(u, m, n, x(:, i));
%   end
%   v = m ./ (n - 1);
%   s = sqrt(v);
%
% REFERENCES
%   (1) Wikipedia: Algorithms for calculating variance.
%   (2) Donald E. Knuth (1998). The Art of Computer Programming,
%   volume 2: Seminumerical Algorithms, 3rd edn., p. 232. Boston:
%   Addison-Wesley.
%

function [u2, m2, n2] = rec_var(u1, m1, n1, x)

nu = size(u1); 
nm = size(m1); 
nx = size(x);
if ~isequal(nu, nm) || ~isequal(nm, nx)
  error('input vector dimensions must match')
end

n2 = n1 + 1;
d  = x - u1;
u2 = u1 + d ./ n2;
m2 = m1 + d .* (x - u2);

