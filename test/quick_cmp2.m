%
% quick comparison of two new ccast runs
%

addpath ../source
addpath ../motmsc/time
addpath ../motmsc/utils

p1 = '/asl/data/cris/ccast/SDR_j01_s45_fudge/2018/005';
p2 = '/asl/data/cris/ccast/SDR_j01_s45/2018/005';

% gran = 'CrIS_SDR_j01_s45_d20180105_t0606010_g062_v20a.mat';
% gran = 'CrIS_SDR_j01_s45_d20180105_t0954010_g100_v20a.mat';
  gran = 'CrIS_SDR_j01_s45_d20180105_t1000010_g101_v20a.mat';  %
% gran = 'CrIS_SDR_j01_s45_d20180105_t1006010_g102_v20a.mat';  %
% gran = 'CrIS_SDR_j01_s45_d20180105_t1012010_g103_v20a.mat';
% gran = 'CrIS_SDR_j01_s45_d20180105_t1018010_g104_v20a.mat';  %
% gran = 'CrIS_SDR_j01_s45_d20180105_t1024010_g105_v20a.mat';  %
% gran = 'CrIS_SDR_j01_s45_d20180105_t1030010_g106_v20a.mat';

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

subplot(2,1,1)
plot(x1, b1 - b1(:, 7))
axis([650, 1150, -1, 1])
title('all fovs minus fov 7, fudged')
set(gcf, 'DefaultAxesColorOrder', fovcolors);
legend(fovnames, 'location', 'eastoutside')
grid on

subplot(2,1,2)
plot(x1, b2 - b2(:, 7))
title('all fovs minus fov 7, unfudged')
axis([650, 1150, -1, 1])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
legend(fovnames, 'location', 'eastoutside')
grid on



