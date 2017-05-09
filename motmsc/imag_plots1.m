%
% imag_plots1 -- plot stats from imag_stats1
%

addpath utils
addpath /home/motteler/matlab/export_fig

fname = fovnames;
fcolor = fovcolors;

% LW plots
figure(1); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fcolor);
subplot(2,1,1)
plot(vLW, cmLW)
axis([650, 1100, -0.1, 0.1])
title('mean complex residuals')
legend(fname, 'location', 'eastoutside')
% xlabel('wavenumber')
ylabel('radiance')
grid on; zoom on

subplot(2,1,2)
plot(vLW, csLW)
axis([650, 1100, 0.05, 0.15])
title('standard deviations')
legend(fname, 'location', 'eastoutside')
xlabel('wavenumber')
ylabel('radiance')
grid on; zoom on

% MW plots
figure(2); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fcolor);
subplot(2,1,1)
plot(vMW, cmMW)
axis([1200, 1750, -0.05, 0.15])
title('mean complex residuals')
legend(fname, 'location', 'eastoutside')
% xlabel('wavenumber')
ylabel('radiance')
grid on; zoom on

subplot(2,1,2)
plot(vMW, csMW)
axis([1200, 1750, 0, 0.20])
title('standard deviations')
legend(fname, 'location', 'eastoutside')
xlabel('wavenumber')
ylabel('radiance')
grid on; zoom on

% SW plots
figure(3); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fcolor);
subplot(2,1,1)
plot(vSW, cmSW)
axis([2150, 2550, -0.02, 0.02])
title('mean complex residuals')
legend(fname, 'location', 'eastoutside')
% xlabel('wavenumber')
ylabel('radiance')
grid on; zoom on

subplot(2,1,2)
plot(vSW, csSW)
axis([2150, 2550, 0, 0.02])
title('standard deviations')
legend(fname, 'location', 'eastoutside')
xlabel('wavenumber')
ylabel('radiance')
grid on; zoom on

