%
% imag_resid1 -- a quick look at complex residuals and NEdN
%

load /asl/data/cris/ccast//sdr60_hr/2017/004/SDR_d20170104_t0809308.mat

bLW = rad2bt(vLW, rLW);

b5LW = reshape(squeeze(bLW(:, 5, :, :)), 717, 30 * 60);
c5LW = reshape(squeeze(cLW(:, 5, :, :)), 717, 30 * 60);
c5MW = reshape(squeeze(cMW(:, 5, :, :)), 869, 30 * 60);
c5SW = reshape(squeeze(cSW(:, 5, :, :)), 637, 30 * 60);

mb5LW = mean(b5LW, 2);
sb5LW = std(b5LW, 0, 2);

mc5LW = mean(c5LW, 2);
sc5LW = std(c5LW, 0, 2);

mc5MW = mean(c5MW, 2);
sc5MW = std(c5MW, 0, 2);

mc5SW = mean(c5SW, 2);
sc5SW = std(c5SW, 0, 2);

figure(1)
subplot(2,1,1)
plot(vLW, mb5LW)
axis([650, 1100, 200, 300])
title('granule mean Tb')
ylabel('Tb, K')
grid on; zoom on

subplot(2,1,2)
plot(vLW, sb5LW)
axis([650, 1100, 0, 25])
title('granule std Tb')
xlabel('wavenumber')
ylabel('Tb, K')
grid on; zoom on
% saveas(gcf, 'gran_LW_Tb', 'png')

figure(2)
subplot(2,1,1)
plot(vLW, mc5LW)
axis([650, 1100, -0.2, 0.2])
title('LW complex radiance residual mean')
xlabel('wavenumber')
ylabel('radiance')
grid on; zoom on

subplot(2,1,2)
plot(vLW, sc5LW)
axis([650, 1100, 0, 1])
title('LW complex radiance residual std')
ylabel('radiance')
grid on; zoom on
% saveas(gcf, 'LW_imag', 'png')

figure(3)
subplot(2,1,1)
plot(vMW, mc5MW)
axis([1200, 1750, 0, 0.08])
title('MW complex radiance residual mean')
xlabel('wavenumber')
ylabel('radiance')
grid on; zoom on

subplot(2,1,2)
plot(vMW, sc5MW)
axis([1200, 1750, 0.03, 0.07])
title('MW complex radiance residual std')
ylabel('radiance')
grid on; zoom on
% saveas(gcf, 'MW_imag', 'png')

figure(4)
subplot(2,1,1)
plot(vLW, mean(reshape(nLW, 717, 18), 2))
axis([650, 1100, 0, 1])
title('LW NEdN')
ylabel('radiance')
grid on; zoom on

subplot(2,1,2)
plot(vMW, mean(reshape(nMW, 869, 18), 2))
axis([1200, 1750, 0.05, 0.09])
title('MW NEdN')
xlabel('wavenumber')
ylabel('radiance')
grid on; zoom on
% saveas(gcf, 'gran_NEdN', 'png')

figure(5)
subplot(2,1,1)
plot(vSW, sc5SW)
axis([2150, 2550, 4e-3, 10e-3])
title('SW complex radiance residual std')
ylabel('radiance')
grid on; zoom on

subplot(2,1,2)
plot(vSW, mean(reshape(nSW, 637, 18), 2))
axis([2150, 2550, 6e-3, 10e-3])
title('SW NEdN')
xlabel('wavenumber')
ylabel('radiance')
grid on; zoom on
% saveas(gcf, 'SW_imag', 'png')

