%
% quick look at one ccast granule
%

p1 = '/asl/data/cris/ccast/default/SDR_j01_s45/2018/009';
% gran = 'CrIS_SDR_j01_s45_d20180109_t0836010_g087_v20a.mat';
% gran = 'CrIS_SDR_j01_s45_d20180109_t0648010_g069_v20a.mat';
% gran = 'CrIS_SDR_j01_s45_d20180109_t0654010_g070_v20a.mat';

p1 = '/asl/data/cris/ccast/default/SDR_j01_s45/2018/011';
% gran = 'CrIS_SDR_j01_s45_d20180111_t0124010_g015_v20a.mat';
% gran = 'CrIS_SDR_j01_s45_d20180111_t0130010_g016_v20a.mat';
  gran = 'CrIS_SDR_j01_s45_d20180111_t0142010_g018_v20a.mat';

f1 = fullfile(p1, gran);
d1 = load(f1);

t1 = d1.geo.FORTime;
[datestr(iet2dnum(t1(1))), '  ', datestr(iet2dnum(t1(end)))]
[d1.geo.Latitude(1), d1.geo.Longitude(1)]

x1 = d1.vLW;
y1 = mean(d1.rLW(:, :, :), 3);
b1 = rad2bt(x1, y1);

figure(1); clf
subplot(2,1,1)
plot(x1, b1)
axis([650, 1150, 200, 300])
title('all fovs')
set(gcf, 'DefaultAxesColorOrder', fovcolors);
legend(fovnames, 'location', 'eastoutside')
grid on

subplot(2,1,2)
plot(x1, b1 - b1(:, 7))
axis([650, 1150, -1, 1])
title('all fovs minus fov 7')
set(gcf, 'DefaultAxesColorOrder', fovcolors);
legend(fovnames, 'location', 'eastoutside')
grid on

