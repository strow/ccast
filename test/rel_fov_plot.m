
addpath ../motmsc/utils

d1 = load('fov_mean_atbd_06');
d2 = load('fov_mean_fudge_06');

b1 = real(rad2bt(v, d1.rmean));
b2 = real(rad2bt(v, d2.rmean));

fname = fovnames;
fcolor = fovcolors;

side = [2 4 6 8];
corn = [1 3 7 9];
ix = 1:9;

figure(1); clf
set(gcf, 'DefaultAxesColorOrder', fcolor(ix,:));
plot(v, b2(:,ix) - b1(:,ix))
axis([650,1100, -0.7, 0.7])
title('mean fudge minus reference')
legend(fname(ix), 'location', 'north')
grid on

return

figure(2)
iref = 7;
subplot(2,1,1)
plot(v, b1 - b1(:,iref))
axis([650,1100, -0.7, 0.7])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
legend(fovnames, 'location', 'eastoutside')
title('no fudge')

grid on

subplot(2,1,2)
plot(v, b2 - b2(:,iref))
axis([650,1100, -0.7, 0.7])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
legend(fovnames, 'location', 'eastoutside')
title('UW fudge')
grid on
