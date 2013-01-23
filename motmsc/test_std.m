
% test of recursive std

nrow = 100;
ncol = 200;

x = randn(nrow, ncol)*100;
s = zeros(nrow,1);
n = 0;

m = mean(x, 2);

for i = 1 : ncol

  [s, n] =  rec_std(m, s, n, x(:,i));

end

s = sqrt(s);

q = std(x, 1, 2);
r1 = rms(s - q) / rms(q)
r2 = max(abs(s - q)) / rms(q)

isequal(n, ncol)

