
cdir = '/asl/data/cris/ccast/SDR_j01_s45/2018/006';
% gran = 'CrIS_SDR_j01_s45_d20180106_t0724010_g075_v20a.mat';
  gran = 'CrIS_SDR_j01_s45_d20180106_t0748010_g079_v20a.mat';

load(fullfile(cdir, gran))

r1 = squeeze(rLW(:, 5, 15, :));
r2 = squeeze(rLW(:, :, 15, 1));
b2 = rad2bt(vLW, r2);
plot(vLW, b2)
axis([650, 1100, 190, 300])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
legend(fovnames, 'location', 'south')
grid on

