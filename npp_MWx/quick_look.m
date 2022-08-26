%
% quick look at one ccast granule
%

addpath /home/motteler/cris/ccast/source
addpath /home/motteler/cris/ccast/motmsc/time
addpath /home/motteler/cris/ccast/motmsc/utils

p1 = '/asl/cris/ccast/sdr45_npp_HR/2021/194';
gran = 'CrIS_SDR_npp_s45_d20210713_t0136080_g017_v20d.mat';

f1 = fullfile(p1, gran);
d1 = load(f1);

t1 = d1.geo.FORTime;
[datestr(iet2dnum(t1(1))), '  ', datestr(iet2dnum(t1(end)))]
[d1.geo.Latitude(1), d1.geo.Longitude(1)]

x1 = d1.vLW;
y1 = mean(d1.rLW(:, :, :), 3);
b1 = real(rad2bt(x1, y1));

figure(1); clf
subplot(2,1,1)
plot(x1, b1)
xlim([650,1150])
title('LW all fovs')
set(gcf, 'DefaultAxesColorOrder', fovcolors);
legend(fovnames, 'location', 'eastoutside')
grid on

subplot(2,1,2)
plot(x1, b1 - b1(:, 5))
axis([650, 1150, -1, 1])
title('all fovs minus fov 5')
set(gcf, 'DefaultAxesColorOrder', fovcolors);
legend(fovnames, 'location', 'eastoutside')
grid on

x1 = d1.vSW;
y1 = mean(d1.rSW(:, :, :), 3);
b1 = real(rad2bt(x1, y1));

figure(2); clf
subplot(2,1,1)
plot(x1, b1)
xlim([2150,2550])
title('SW all fovs')
set(gcf, 'DefaultAxesColorOrder', fovcolors);
legend(fovnames, 'location', 'eastoutside')
grid on

subplot(2,1,2)
plot(x1, b1 - b1(:, 5))
% axis([650, 1150, -1, 1])
title('all fovs minus fov 5')
set(gcf, 'DefaultAxesColorOrder', fovcolors);
legend(fovnames, 'location', 'eastoutside')
grid on

