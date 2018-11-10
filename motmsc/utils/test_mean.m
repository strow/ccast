
% test of recursive mean

nrow = 100; ncol = 200;
x = randn(nrow, ncol)*100;
u = zeros(nrow,1); n = 0;

for i = 1 : ncol
  [u, n] =  rec_mean(u, n, x(:,i));
end

q = mean(x, 2);
r1 = rms(u - q) / rms(q)
r2 = max(abs(u - q)) / rms(q)
isequal(n, ncol)

