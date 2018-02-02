
addpath ../source
addpath ../motmsc/utils

d1 = load('npp_mean_std');
d2 = load('j1_mean_std');

v1 = d1.vSW;
m1 = d1.mSW;
m2 = d2.mSW;
s1 = d1.sSW;
s2 = d2.sSW;

% side = [2 4 6 8];
% corn = [1 3 7 9];
% iFOV = 1:9

figure(1); clf
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(v1, m2 - m1);
axis([2370, 2390, -2.2, 1.8])
title('J1 minus NPP 7-day mean')
legend(fovnames, 'location', 'northwest')
ylabel('dTb, K')
xlabel('wavenum, cm-1')
grid on
saveas(gcf, 'j1_minus_npp_mean', 'png')

figure(2); clf
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(v1, s2 - s1);
axis([2370, 2390, -0.5, 1.5])
title('J1 minus NPP 7-day standard dev')
legend(fovnames, 'location', 'northwest')
ylabel('dTb, K')
xlabel('wavenum, cm-1')
grid on
saveas(gcf, 'j1_minus_npp_std', 'png')

return

figure(3); clf
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(v1, m2 - m1);
axis([2150, 2550, -3.5, 1])
title('J1 minus NPP 7-day mean')
legend(fovnames, 'location', 'southeast')
ylabel('dTb, K')
xlabel('wavenum, cm-1')
grid on


