%
% NAME
%   movavg1 -- vectorized moving average with NaNs
%
% SYNOPSIS
%   b = movavg1(a, k)
%
% INPUTS
%   a  - m x n input array
%   k  - 2*k+1 span moving average
%
% OUTPUT
%   b  - "a" with a moving average taken along rows
%
% DISCUSSION
%
% The span of the moving average is 2*k+1, centered in the middle
% and shrinking to k+1 at the interval edges.
%
% This works for 0 <= k < n, note that k = 0 gives b = a, and
% k = n-1 gives the average along the whole rows
%
% The moving average of an interval such as [a b NaN c Nan d] for
% k = 2 is [(a+b)/2,(a+b+c)/3,(a+b+c)/3,(b+c+d)/3,(c+d)/2,(c+d)/2],
% the NaNs are dropped from the averages.
%
% AUTHOR
%   H. Motteler, 25 Nov 2011
%

function b = movavg1(a, k)

% size of 2D array "a"
[m, n] = size(a);

% initialize output array
b = zeros(m, n);  

% if k is too big, take the average along the whole rows
if k >= n
  k = n - 1;
end

% ----------------------
% key internal variables
% ----------------------
%  iLB - index of lower bound of moving average window
%  iUB - index of upper bound of moving average window
%   w  - number of valid (non-NaN) values in the window
%   i  - output position, moving average center in input
%   j  - input positions for initial moving average window
%  iUBp, iLBp, wp - values from previous iteration

% ---------------------------
% get the first output column
% ---------------------------
iLB = 1;
iUB = k + 1;
w = zeros(m, 1);

% loop over the first window,
% add valid elements and increment w
for j = iLB : iUB
  aj = a(:, j);
  iok = ~isnan(aj);
  aj(~iok) = 0;              % set NaNs to 0 for vector add
  b(:, 1) = b(:, 1) + aj;    % add good values to b(:, 1)
  w = w + iok;               % increment w for good values
end

% divide by w for col 1 averages.  
% note that if w is zero then b is also and b/w gives an NaN, 
% which is correct when all values in the window are NaN
b(:, 1) = b(:, 1) ./ w;

% --------------------------------
% loop on remaining output columns
% --------------------------------
for i = 2 : n 

  % save previous UB, LW, and counts
  iLBp = iLB;
  iUBp = iUB;
  wp = w;

  % get window boundaries for this output column
  iLB = max(1, i - k);
  iUB = min(i + k, n);

  % get prev LB column of "a"
  if iLB > 1
    iok = ~isnan(a(:, iLBp));
    aLBp = a(:, iLBp);
    aLBp(~iok) = 0;    % set NaNs to 0 for vector add
    w = w - iok;       % decrement w for old good values
  else 
    aLBp = 0;
  end

  % get next UB column of "a"
  if iUBp < n
    iok = ~isnan(a(:, iUB));
    aUB = a(:, iUB);
    aUB(~iok) = 0;    % set NaNs to 0 for vector add
    w = w + iok;      % increment w for new good values
  else
    aUB = 0;
  end

  % update the moving averages for this output column
  bp = b(:, i-1);
  ibad = isnan(bp);
  bp(ibad) = 0;
  b(:, i) = ((bp .* wp) - aLBp + aUB) ./ w;

end

