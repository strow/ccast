%
% tests for seq_match
%

% create sequences that converge to a single pair

d = 1 : 100;
d = cumsum(d);
ix = 1 : length(d);
j0 = find(mod(ix, 2) == 0);
j1 = find(mod(ix, 2) == 1);
a = d(j1); b = d(j0);
[i, j] = seq_match(a, b);

% log sequence test

a = exp(0:.01:1);
b = exp(0:.01:1) + 0.5;
% b = exp(0:.02:2);
[i, j] = seq_match(a, b);

% random sequence test

for k = 1 : 10000

  m = round(rand * 1e5) + 1;
  n = round(rand * 1e5) + 1;

  w1 = rand * 1000;
  w2 = rand * 1000;

% a = sort(w1 * randn(m,1));
% b = sort(w2 * randn(n,1));

  a = unique(round(w1 * (randn(m,1) + 2 * rand)));
  b = unique(round(w2 * (randn(n,1) + 2 * rand)));

  if length(a) < 2 || length(b) < 2, continue, end

  [i, j] = seq_match(a, b);

  [c, ia, ib] = intersect(a, b);
end


