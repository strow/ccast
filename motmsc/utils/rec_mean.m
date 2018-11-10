%
% NAME
%   rec_mean -- recursive mean
%
% SYNOPSIS
%   [u2, n2] = rec_mean(u1, n1, x)
%
% INPUTS
%   u1   - current mean
%   n1   - current count
%   x    - next data value
%   
% OUTPUTS
%   u2   - updated mean
%   n2   - updated count
%
% EXAMPLE
%   nrow = 100; ncol = 200;
%   x = randn(nrow, ncol)*100;
%   u = zeros(nrow,1); n = 0;
%   for i = 1 : ncol
%     [u, n] =  rec_mean(u, n, x(:,i));
%   end
%   q = mean(x, 2);
%   r = rms(m - q) / rms(q)
%   isequal(n, ncol)
% 
% AUTHOR
%  H. Motteler, 6 Nov 2012
%

function [u2, n2] = rec_mean(u1, n1, x)

nu = size(u1);
nx = size(x);
if ~isequal(nu, nx)
  error('input vector dimensions must match')
end

n2 = n1 + 1;
u2 = u1 .* (n1/n2) + x ./ n2;

