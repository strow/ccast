% 
% atest3 -- vectorized moving average
%
% compute moving averages over rows of "a"
%
% The span of the moving average is 2*k+1, centered in the middle
% and shrinking to k+1 at the interval edges.
%

m = 8;   % test array rows
n = 8;   % test array cols
k = 4;   % for 2*k+1 span moving average

% input array
% a = ones(m, n);   
% a = zeros(m, n)
a = eye(m); n = m;

% output array
b = zeros(m, n);  

% setup
iLB = 1;
iUB = k + 1;
w = iUB - iLB + 1;

for i = iLB : iUB
  b(:, 1) = b(:, 1) + a(:, i);
end

b(:, 1) = b(:, 1) / w;

% loop
for i = 2 : n 

  iLBp = iLB;
  iUBp = iUB;
  wp = w;

  iLB = max(1, i - k);
  iUB = min(i + k, n);
  w = iUB - iLB + 1;

  if iLB > 1
    d1 = a(:, iLBp);
  else 
    d1 = 0;
  end

  if iUBp < n
    d2 = a(:, iUB);
  else
    d2 = 0;
  end

  b(:, i) = ((b(:, i-1) * wp) - d1 + d2) / w;

% fprintf(1, 'iLB=%d i=%d iUB=%d b(i)=%0.2f\n', iLB, i, iUB, b(i))

end

