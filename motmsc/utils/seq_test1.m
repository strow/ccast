%
% tests for seq_match
%

[i, j] = seq_match([2, 3, 4], [3.9, 4, 4.1]);
isequal([i,j], [3,2])

[i, j] = seq_match([2, 3, 4], [3.2, 3.9, 4, 4.1]);
isequal([i, j], [[2; 3],[1; 3]])

a = [3.0 4.0 4.7 5.1 5.2 6.2 7.0 8.0 8.1 8.9];
b = [1.0 2.0 3.1 3.9 5.0 6.0 6.1 6.9];
[i, j] = seq_match(a, b);
isequal(a(i), [3.0  4.0  5.1  6.2  7.0])
isequal(b(j), [3.1  3.9  5.0  6.1  6.9]) 

% disjoint sequences
a = [1 2 3];  b = [4 5 6] 
[i, j] = seq_match(a, b);
isequal([a(i), b(j)], [3,4])

% an example of sequences a and b that converge to a single pair of
% values if iteration continues past the point where the sequence
% lengths are equal

d = 1 : 12;
d = cumsum(d);

ix = 1 : length(d);
j0 = find(mod(ix, 2) == 0);
j1 = find(mod(ix, 2) == 1);

a = d(j1); b = d(j0);
a
b
b - a
a(2:end) - b(1:end-1)

[i, j] = seq_match(a, b);

% random sequence test

m = 4000;
n = 3000;
s = 200;
d = .05;

for k = 1 : 20
  a = sort(s*randn(m,1));
  b = sort(s*1.2*randn(n,1));
  [i, j] = seq_match(a, b, d);
  fprintf(1, 'rms(a(i) - b(j)) = %d, length = %d \n', ...
              rms(a(i) - b(j)), length(i))
end

