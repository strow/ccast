%
% quick comparison of two new ccast runs
%

addpath ../source
addpath ../motmsc/time
addpath ../motmsc/utils

  p1 = '/asl/cris/ccast/sdr45_npp_HR/2016/017';
  p2 = '/asl/cris/ccast_umbc_a2_new_ict/sdr45_npp_HR/2016/017';
  gran = 'CrIS_SDR_npp_s45_d20160117_t0306010_g032_v20a.mat';
% gran = 'CrIS_SDR_npp_s45_d20160117_t1142010_g118_v20a.mat';

f1 = fullfile(p1, gran);
f2 = fullfile(p2, gran);

d1 = load(f1);
d2 = load(f2);

t1 = d1.geo.FORTime;
[datestr(iet2dnum(t1(1))), '  ', datestr(iet2dnum(t1(end)))]
[d1.geo.Latitude(1), d1.geo.Longitude(1)]

vLW = d1.vLW;
b1 = real(rad2bt(vLW, d1.rLW));
b2 = real(rad2bt(vLW, d2.rLW));
y1 = mean(b1(:, :, :), 3);
y2 = mean(b2(:, :, :), 3);

figure(1); clf
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(vLW, y2 - y1)
title('LW granule 2 minus granule 1 means')
xlim([650, 1100])
legend(fovnames, 'location', 'northeast')
xlabel('wavenumber (cm-1)')
ylabel('dBT (K)')
grid on

vMW = d1.vMW;
b1 = real(rad2bt(vMW, d1.rMW));
b2 = real(rad2bt(vMW, d2.rMW));
y1 = mean(b1(:, :, :), 3);
y2 = mean(b2(:, :, :), 3);

figure(2); clf
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(vMW, y2 - y1)
title('MW granule 2 minus granule 1 means')
xlim([1200, 1750])
legend(fovnames, 'location', 'northwest')
xlabel('wavenumber (cm-1)')
ylabel('dBT (K)')
grid on

vSW = d1.vSW;
b1 = real(rad2bt(vSW, d1.rSW));
b2 = real(rad2bt(vSW, d2.rSW));
y1 = mean(b1(:, :, :), 3);
y2 = mean(b2(:, :, :), 3);

figure(3); clf
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(vSW, y2 - y1)
title('SW granule 2 minus granule 1 means')
xlim([2150, 2550])
legend(fovnames, 'location', 'southeast')
xlabel('wavenumber (cm-1)')
ylabel('dBT (K)')
grid on

return

figure(4)
set(gcf, 'DefaultAxesColorOrder', fovcolors);
subplot(2,1,1)
plot(vSW, y1 - y1(:, 5))
xlim([2150, 2550])
title('SW all FOVs minus FOV 5, granule 1')
legend(fovnames, 'location', 'eastoutside')
ylabel('dBT (K)')
grid on

subplot(2,1,2)
plot(vSW, y2 - y2(:, 5))
xlim([2150, 2550])
title('SW all FOVs minus FOV 5, granule 2')
legend(fovnames, 'location', 'eastoutside')
xlabel('wavenumber (cm-1)')
ylabel('dBT (K)')
grid on

