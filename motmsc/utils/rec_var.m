%
% NAME
%   rec_var -- one-pass recursive variance
%
% SYNOPSIS
%   [m2, w2, n2] = rec_var(m1, w1, n1, x)
%
% INPUTS
%   m1   - previous recursive mean
%   w1   - previous sum((x - mean(x))^2)
%   n1   - previous recursive count
%   x    - next data value
%   
% OUTPUTS
%   m2   - current recursive mean
%   w2   - current sum((x - mean(x))^2)
%   n2   - current recursive count
%
%   variance = w2 / (n2 - 1)
%
% EXAMPLE
%   nrow = 100; ncol = 200;
%   x = randn(nrow, ncol) * 20;
%   m = zeros(nrow, 1);
%   w = zeros(nrow, 1);
%   n = 0;
%   for i = 1 : ncol
%     [m, w, n] = rec_var(m, w, n, x(:, i));
%   end
%   v = w ./ (n - 1);
%   s = sqrt(v);
%
% REFERENCE
%   Donald E. Knuth (1998). The Art of Computer Programming, volume 2:
%   Seminumerical Algorithms, 3rd edn., p. 232. Boston: Addison-Wesley.
%

function [m2, w2, n2] = rec_var(m1, w1, n1, x)

% m1 = m1(:);
% w1 = w1(:);
% x = x(:);

n2 = n1 + 1;
d  = x - m1;
m2 = m1 + d ./ n2;
w2 = w1 + d .* (x - m2);

