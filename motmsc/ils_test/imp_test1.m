%
% imp_test1 - show finterp impulse response is a sinc function
%
% integral cos 2 pi v x dx from -d to d = 2 d sinc 2 pi v d
% matlab sinc(x) = sin(pi*x)/(pi*x), and note that d = 1/(2*dv)
% so the 2's cancel out, giving sinc((v - vimp) / dv)
%

% high res impulse
dv1 = 0.01;
v1 = 800;
v2 = 1600;
n1 = round((v2 - v1) / dv1) + 1;
frq1 = (v1 + (0 : n1 - 1) * dv1)';

% ix = floor(n1/3);
% ix = floor(2*n1/3);
  ix = floor(n1/2);
vimp = frq1(ix);

rad1 = zeros(n1, 1);
rad1(ix, 1) = 1;

% low res transform
dv2 = 0.625;
[rad2, frq2] = finterp(rad1, frq1, dv2);
rad2 = real(rad2);
rad2 = rad2 ./ sum(rad2);

% sinc and psinc values
vx = (frq2 - vimp) / dv2;
rad3 = sinc(vx);
rad4 = psinc(vx, length(vx));
fprintf(1, 'psinc period = %d\n', length(vx))

% summary plots
figure(1); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(3,1,1)
plot(frq2, rad2, frq2, rad3)
ax = axis; ax(3) = -0.2; axis(ax);
title('interpolated impulse and sinc functions')
legend('impulse', 'regular sinc')
grid on; zoom on

subplot(3,1,2)
plot(frq2, rad2 - rad3)
title('interpolated impulse minus regular sinc')
grid on; zoom on

subplot(3,1,3)
plot(frq2, rad2 - rad4)
title('interpolated impulse minus periodic sinc')
grid on; zoom on

