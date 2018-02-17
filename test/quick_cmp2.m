%
% quick comparison of two new ccast runs
%

addpath ../source
addpath ../motmsc/time
addpath ../motmsc/utils

  p1 = '/asl/data/cris/ccast/a2v4_ref/sdr45_j01_HR/2018/036';
% p1 = '/asl/data/cris/ccast/noaa_a4/sdr45_j01_HR/2018/036';
% p2 = '/asl/data/cris/ccast/noaa_a4X/sdr45_j01_HR/2018/036';
  p2 = '/asl/data/cris/ccast/noaa_a4Y/sdr45_j01_HR/2018/036';
gran = 'CrIS_SDR_j01_s45_d20180205_t0100080_g011_v20a.mat';

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

figure(1)
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(vLW, y2 - y1)
title('set 2 minus set 1 means')
axis([650, 1100, -0.3, 0.3])
legend(fovnames, 'location', 'northeast')
grid on

vSW = d1.vSW;
b1 = real(rad2bt(vSW, d1.rSW));
b2 = real(rad2bt(vSW, d2.rSW));
y1 = mean(b1(:, :, :), 3);
y2 = mean(b2(:, :, :), 3);

figure(2)
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(vSW, y2 - y1)
title('set 2 minus set 1 means')
axis([2150, 2550, -0.3, 0.3])
legend(fovnames, 'location', 'southwest')
grid on

return

figure(3)
set(gcf, 'DefaultAxesColorOrder', fovcolors);
subplot(2,1,1)
plot(x1, b1 - b1(:, 5))
% axis([650, 1150, -1, 1])
  axis([2150, 2550, -1, 1])
title('all fovs minus fov 5, set 1')
legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
grid on

subplot(2,1,2)
plot(x1, b2 - b2(:, 5))
% axis([650, 1150, -1, 1])
  axis([2150, 2550, -1, 1])
title('all fovs minus fov 5, set 2')
legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
grid on

