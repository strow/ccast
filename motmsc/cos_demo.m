% 
% cosine transform demo
%
% do an inverse and forward transform, and compare the final result
% with the original value.  Note that x1 and z1 are very close, and
% the complex components of z1 and z2 are very small.
%
% the indicies for the concatenations below are
%
%    [1, 2, ..., n-1, n, n+1, n, n-1, ..., 3, 2]
%

n = 101;
x1 = rand(n,1);

x2 = [x1; flipud(x1(2:n-1,1))];
y2 = ifft(x2);
y1 = y2(1:n);

y2 = [y1; flipud(y1(2:n-1,1))];
z2 = fft(y2);
z1 = z2(1:n);

max(abs(x1 - z1)) / rms(x1)
max(imag(z2))
max(imag(z1))

