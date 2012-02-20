% 
% atest4 -- vectorized moving average with NaNs
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
k = 2;   % for 2*k+1 span moving average

% input array
a = ones(m, n);   
a(rand(m,n) > .6) = NaN;

% a = zeros(m, n)
% a = eye(m); n = m;
% a(rand(m,n) > .8) = NaN;

% a = rand(m,n);

% initialize output array
b = zeros(m, n);  

% working variables
%  iLB - index of lower bound of moving average window
%  iUB - index of upper bound of moving average window
%   i  - output position, moving average center in input
%   w  - number of valid (non-NaN) values in the window
%  iUBp, iLBp, wp - values from previous iteration

% ---------------------------
% get the first output column
% ---------------------------
iLB = 1;
iUB = k + 1;
w = zeros(m, 1);

% loop over the first window,
% add valid elements and increment w
for i = iLB : iUB
  ai = a(:, i);
  iok = ~isnan(ai);
  ai(~iok) = 0;              % set NaNs to 0 for vector add
  b(:, 1) = b(:, 1) + ai;    % add good values to b(:, 1)
  w = w + iok;               % increment w for good values
end

% divide by w and change any Infs to NaNs
b(:, 1) = b(:, 1) ./ w;
% b(w == 0, 1) = NaN;

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

% show the result
b

