
% test of recursive variance

nrow = 100;
ncol = 200;

x = randn(nrow, ncol) * 20;
m = zeros(nrow, 1);
w = zeros(nrow, 1);
n = 0;

for i = 1 : ncol
  [m, w, n] = rec_var(m, w, n, x(:, i));
end

v = w ./ (n - 1);
s = sqrt(v);

s1 = std(x, 0, 2);
isclose(s, s1, 4)

isequal(n, ncol)

m1 = mean(x, 2);
isclose(m, m1, 6)

% direct calc from mean
s2 = sqrt(sum((x - m * ones(1, ncol)).^2, 2) ./ (ncol - 1));
isclose(s2, s1, 4)



