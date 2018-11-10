
% test of recursive variance

nrow = 100; ncol = 200;
x = randn(nrow, ncol) * 20;
u = zeros(nrow, 1); m = u; n = 0;

for i = 1 : ncol
  [u, m, n] = rec_var(u, m, n, x(:, i));
end

v = m ./ (n - 1);
s = sqrt(v);

s1 = std(x, 0, 2);
isclose(s, s1, 4)

isequal(n, ncol)

u1 = mean(x, 2);
isclose(u, u1, 6)

% direct calc from mean
s2 = sqrt(sum((x - u * ones(1, ncol)).^2, 2) ./ (ncol - 1));
isclose(s2, s1, 4)



