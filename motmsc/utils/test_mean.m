
% test of recursive mean

nrow = 100;
ncol = 200;

x = randn(nrow, ncol)*100;
m = zeros(nrow,1);
n = 0;

for i = 1 : ncol

  [m, n] =  rec_mean(m, n, x(:,i));

end

q = mean(x, 2);
r1 = rms(m - q) / rms(q)
r2 = max(abs(m - q)) / rms(q)

isequal(n, ncol)

