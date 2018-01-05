
% load SDR_test/SDR_j01_s45/CrIS_SDR_j01_s45_d20180105_t0312010_c0a1bce.mat
  load SDR_test/SDR_j01_s45/CrIS_SDR_j01_s45_d20180105_t0200010_c0a1bce.mat

r1 = squeeze(rLW(:, 5, 15, :));
r2 = squeeze(rLW(:, :, 15, 1));
b2 = rad2bt(vLW, r2);
plot(vLW, b2)
axis([650, 1100, 190, 300])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
legend(fovnames, 'location', 'south')
grid on



