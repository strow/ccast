% 
% atest5 -- test wrapper for movavg1
%
% compute moving average along rows of "a"
%
% The span of the moving average is 2*k+1, centered in the middle
% and shrinking to k+1 at the interval edges.
%
% This works for 0 <= k < n, k = 0 gives b = a
%

m = 8;   % test array rows
n = 8;   % test array cols
k = 7;   % for 2*k+1 span moving average

% input array
a = ones(m, n);   
a(rand(m,n) > .3) = NaN;

% a = zeros(m, n)
% a = eye(m); n = m;
% a(rand(m,n) > .8) = NaN;

% a = rand(m,n);

b = movavg1(a, k);

% show the result
b

