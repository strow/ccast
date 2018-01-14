%
% quick comparison of two new ccast runs
%

addpath ../source
addpath ../motmsc/time
addpath ../motmsc/utils

p1 = '/asl/data/cris/ccast/SDR_j01_s45/2018/008';
p2 = '/asl/data/cris/ccast/SDR_j01_s45/testX/2018/008';
gran = 'CrIS_SDR_j01_s45_d20180108_t0024010_g005_v20a.mat';

% p1 = '/asl/data/cris/ccast/SDR_j01_s45/2018/010';
% p1 = '/asl/data/cris/ccast/e7new/SDR_j01_s45/2018/010';
% p2 = '/asl/data/cris/ccast/e8old/SDR_j01_s45/2018/010';
% gran = 'CrIS_SDR_j01_s45_d20180110_t0024010_g005_v20a.mat';

f1 = fullfile(p1, gran);
f2 = fullfile(p2, gran);

d1 = load(f1);
d2 = load(f2);

t1 = d1.geo.FORTime;
[datestr(iet2dnum(t1(1))), '  ', datestr(iet2dnum(t1(end)))]
[d1.geo.Latitude(1), d1.geo.Longitude(1)]

x1 = d1.vLW;
y1 = mean(d1.rLW(:, :, :), 3);
y2 = mean(d2.rLW(:, :, :), 3);
b1 = rad2bt(x1, y1);
b2 = rad2bt(x1, y2);

figure(1)
plot(x1, b2 - b1)
set(gcf, 'DefaultAxesColorOrder', fovcolors);
legend(fovnames, 'location', 'eastoutside')
grid on

figure(2)
subplot(2,1,1)
plot(x1, b1 - b1(:, 7))
axis([650, 1150, -1, 1])
title('all fovs minus fov 7, set 1')
set(gcf, 'DefaultAxesColorOrder', fovcolors);
legend(fovnames, 'location', 'eastoutside')
grid on

subplot(2,1,2)
plot(x1, b2 - b2(:, 7))
title('all fovs minus fov 7, set 2')
axis([650, 1150, -1, 1])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
legend(fovnames, 'location', 'eastoutside')
grid on

