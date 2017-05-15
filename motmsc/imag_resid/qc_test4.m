%
% qc_test4 - sample SDR complex residuals with std bands
% 
% uses data from imag_stats1 or imag_stats2
%

addpath utils

% sample granule for demo
d1 = load('/asl/data/cris/ccast/sdr60_hr/2016/245/SDR_d20160901_t0714247.mat');

load rad_stats_t8

% smooth the residuals
fmLW = gauss_filt(cmLW);
fmMW = gauss_filt(cmMW);
fmSW = gauss_filt(cmSW);

fsLW = gauss_filt(csLW);
fsMW = gauss_filt(csMW);
fsSW = gauss_filt(csSW);

k = 6;
ubLW = fmLW + k * fsLW;
lbLW = fmLW - k * fsLW;

ubMW = fmMW + k * fsMW;
lbMW = fmMW - k * fsMW;

ubSW = fmSW + k * fsSW;
lbSW = fmSW - k * fsSW;

i = 5;
[n1, ~, n3, n4] = size(d1.rLW);
rtmp = reshape(squeeze(d1.cLW(:,i,:,:)), n1, n3*n4);
figure(1); clf
plot(d1.vLW, rtmp)
hold on
plot(vLW, ubLW(:,i), vLW, lbLW(:,i), 'linewidth', 2)
axis([650, 1100, -4, 4])
title(sprintf('LW FOV %d resids with %d std bands', i, k))
grid on; zoom on
hold off

[n1, ~, n3, n4] = size(d1.rMW);
rtmp = reshape(squeeze(d1.cMW(:,i,:,:)), n1, n3*n4);
figure(2); clf
plot(d1.vMW, rtmp)
hold on
plot(vMW, ubMW(:,i), vMW, lbMW(:,i), 'linewidth', 2)
% axis([650, 1100, -4, 4])
title(sprintf('MW FOV %d resids with %d std bands', i, k))
grid on; zoom on
hold off

[n1, ~, n3, n4] = size(d1.rSW);
rtmp = reshape(squeeze(d1.cSW(:,i,:,:)), n1, n3*n4);
figure(3); clf
plot(d1.vSW, rtmp)
hold on
plot(vSW, ubSW(:,i), vSW, lbSW(:,i), 'linewidth', 2)
% axis([650, 1100, -4, 4])
title(sprintf('SW FOV %d resids with %d std bands', i, k))
grid on; zoom on
hold off

