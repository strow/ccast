%
% imag_resid2 -- complex residuals by sweep direction
%

addpath ../source
addpath utils

% load a ccast granule
load /asl/data/cris/ccast/sdr60_hr/2017/004/SDR_d20170104_t0809308.mat
ncLW = length(vLW);
ncMW = length(vMW);
ncSW = length(vSW);

% LW Tb for an overview of the granule
bLW = real(rad2bt(vLW, rLW));
bLW = reshape(bLW, 717, 9 * 30 * 60);
mbLW = mean(bLW, 2);
sbLW = std(bLW, 0, 2);

% even and odd sweep direction indices
ix0 = 2:2:30;
ix1 = 1:2:29;

c0LW = reshape(cLW(:, :, ix0, :), ncLW, 9, 15 * 60);
c1LW = reshape(cLW(:, :, ix1, :), ncLW, 9, 15 * 60);
c0MW = reshape(cMW(:, :, ix0, :), ncMW, 9, 15 * 60);
c1MW = reshape(cMW(:, :, ix1, :), ncMW, 9, 15 * 60);
c0SW = reshape(cSW(:, :, ix0, :), ncSW, 9, 15 * 60);
c1SW = reshape(cSW(:, :, ix1, :), ncSW, 9, 15 * 60);

mc0LW = mean(c0LW, 3);
mc1LW = mean(c1LW, 3);
mc0MW = mean(c0MW, 3);
mc1MW = mean(c1MW, 3);
mc0SW = mean(c0SW, 3);
mc1SW = mean(c1SW, 3);

sc0LW = std(c0LW, 0, 3);
sc1LW = std(c1LW, 0, 3);
sc0MW = std(c0MW, 0, 3);
sc1MW = std(c1MW, 0, 3);
sc0SW = std(c0SW, 0, 3);
sc1SW = std(c1SW, 0, 3);

% LW separate sweeps all FOV means
figure(1)
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
subplot(2,1,1)
plot(vLW, mc0LW)
axis([650, 1100, -0.2, 0.2])
title('LW dir 0 complex residual mean')
legend(fovnames, 'location', 'eastoutside')
ylabel('radiance')
grid on; zoom on

subplot(2,1,2)
plot(vLW, mc1LW)
axis([650, 1100, -0.2, 0.2])
title('LW dir 1 complex residual mean')
legend(fovnames, 'location', 'eastoutside')
xlabel('wavenumber')
ylabel('radiance')
grid on; zoom on
% saveas(gcf, 'LW_imag_means', 'png')

% MW separate sweeps all FOV means
figure(2)
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
subplot(2,1,1)
plot(vMW, mc0MW)
axis([1200, 1750, -0.1, 0.2])
title('MW dir 0 complex residual mean')
legend(fovnames, 'location', 'eastoutside')
ylabel('radiance')
grid on; zoom on

subplot(2,1,2)
plot(vMW, mc1MW)
axis([1200, 1750, -0.1, 0.2])
title('MW dir 1 complex residual mean')
legend(fovnames, 'location', 'eastoutside')
xlabel('wavenumber')
ylabel('radiance')
grid on; zoom on
% saveas(gcf, 'MW_imag_means', 'png')

% SW separate sweeps all FOV means
figure(3)
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
subplot(2,1,1)
plot(vSW, mc0SW)
axis([2150, 2550, -0.03, 0.03])
title('SW dir 0 complex residual mean')
legend(fovnames, 'location', 'eastoutside')
ylabel('radiance')
grid on; zoom on

subplot(2,1,2)
plot(vSW, mc1SW)
axis([2150, 2550, -0.03, 0.03])
title('SW dir 1 complex residual mean')
legend(fovnames, 'location', 'eastoutside')
xlabel('wavenumber')
ylabel('radiance')
grid on; zoom on
% saveas(gcf, 'SW_imag_means', 'png')

% MW separate sweeps all FOV stds
figure(4)
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
subplot(3,1,1)
plot(vLW, sc0LW)
axis([650, 1100, 0, 1])
title('LW dir 0 complex residual standard dev')
legend(fovnames, 'location', 'eastoutside')
ylabel('radiance')
grid on; zoom on

subplot(3,1,2)
plot(vMW, sc0MW)
axis([1200, 1750, 0, 0.2])
title('MW dir 0 complex residual standard dev')
legend(fovnames, 'location', 'eastoutside')
ylabel('radiance')
grid on; zoom on

subplot(3,1,3)
plot(vSW, sc0SW)
axis([2150, 2550, 0, 0.02])
title('SW dir 0 complex residual standard dev')
legend(fovnames, 'location', 'eastoutside')
xlabel('wavenumber')
ylabel('radiance')
grid on; zoom on
% saveas(gcf, 'all_imag_stds', 'png')

return

% granule overvies
figure(1)
subplot(2,1,1)
plot(vLW, mbLW)
axis([650, 1100, 200, 300])
title('granule mean Tb')
ylabel('Tb, K')
grid on; zoom on

subplot(2,1,2)
plot(vLW, sbLW)
axis([650, 1100, 0, 25])
title('granule std Tb')
xlabel('wavenumber')
ylabel('Tb, K')
grid on; zoom on
% saveas(gcf, 'gran_LW_Tb', 'png')
