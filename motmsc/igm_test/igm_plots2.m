
% select day-of-the-year
doy = '054';  % high-res 2nd day

% get the means for the doy
d1 = load(['igm_mean_',doy]);

% get the stds for the doy
d2 = load(['igm_std_',doy]);

% LW real
figure(1); clf
[mask, bmax, bmin] = hires_bitmask('LW');
xLW = 1:length(bmax);
avg = d1.iavg_re_LW;
std = d2.istd_re_LW;
plot(xLW, bmax, xLW, avg+5*std, xLW, avg+std, xLW, avg, ...
      xLW, avg-std, xLW, avg-5*std, xLW, bmin)
title('LW high res real interferogram stats')
legend('+ mask', '+5 std', '+1 std', 'mean', '-1 std', '-5 std', '-mask')
xlabel('igm index')
ylabel('igm count')
grid on; zoom on
saveas(gcf, 'LW_high_res_real_igm_stats', 'png')
saveas(gcf, 'LW_high_res_real_igm_stats', 'fig')

% LW imag
figure(2); clf
[mask, bmax, bmin] = hires_bitmask('LW');
xLW = 1:length(bmax);
avg = d1.iavg_im_LW;
std = d2.istd_im_LW;
plot(xLW, bmax, xLW, avg+5*std, xLW, avg+std, xLW, avg, ...
      xLW, avg-std, xLW, avg-5*std, xLW, bmin)
title('LW high res imag interferogram stats')
legend('+ mask', '+5 std', '+1 std', 'mean', '-1 std', '-5 std', '-mask')
xlabel('igm index')
ylabel('igm count')
grid on; zoom on
saveas(gcf, 'LW_high_res_imag_igm_stats', 'png')
saveas(gcf, 'LW_high_res_imag_igm_stats', 'fig')

% MW real
figure(3); clf
[mask, bmax, bmin] = hires_bitmask('MW');
xMW = 1:length(bmax);
avg = d1.iavg_re_MW;
std = d2.istd_re_MW;
plot(xMW, bmax, xMW, avg+5*std, xMW, avg+std, xMW, avg, ...
      xMW, avg-std, xMW, avg-5*std, xMW, bmin)
title('MW high res real interferogram stats')
legend('+ mask', '+5 std', '+1 std', 'mean', '-1 std', '-5 std', '-mask')
xlabel('igm index')
ylabel('igm count')
grid on; zoom on
saveas(gcf, 'MW_high_res_real_igm_stats', 'png')
saveas(gcf, 'MW_high_res_real_igm_stats', 'fig')

% MW imag
figure(4); clf
[mask, bmax, bmin] = hires_bitmask('MW');
xMW = 1:length(bmax);
avg = d1.iavg_im_MW;
std = d2.istd_im_MW;
plot(xMW, bmax, xMW, avg+5*std, xMW, avg+std, xMW, avg, ...
      xMW, avg-std, xMW, avg-5*std, xMW, bmin)
title('MW high res imag interferogram stats')
legend('+ mask', '+5 std', '+1 std', 'mean', '-1 std', '-5 std', '-mask')
xlabel('igm index')
ylabel('igm count')
grid on; zoom on
saveas(gcf, 'MW_high_res_imag_igm_stats', 'png')
saveas(gcf, 'MW_high_res_imag_igm_stats', 'fig')

% SW real
figure(5); clf
[mask, bmax, bmin] = hires_bitmask('SW');
xSW = 1:length(bmax);
avg = d1.iavg_re_SW;
std = d2.istd_re_SW;
plot(xSW, bmax, xSW, avg+5*std, xSW, avg+std, xSW, avg, ...
      xSW, avg-std, xSW, avg-5*std, xSW, bmin)
title('SW high res real interferogram stats')
legend('+ mask', '+5 std', '+1 std', 'mean', '-1 std', '-5 std', '-mask')
xlabel('igm index')
ylabel('igm count')
grid on; zoom on
saveas(gcf, 'SW_high_res_real_igm_stats', 'png')
saveas(gcf, 'SW_high_res_real_igm_stats', 'fig')

% SW imag
figure(6); clf
[mask, bmax, bmin] = hires_bitmask('SW');
xSW = 1:length(bmax);
avg = d1.iavg_im_SW;
std = d2.istd_im_SW;
plot(xSW, bmax, xSW, avg+5*std, xSW, avg+std, xSW, avg, ...
      xSW, avg-std, xSW, avg-5*std, xSW, bmin)
title('SW high res imag interferogram stats')
legend('+ mask', '+5 std', '+1 std', 'mean', '-1 std', '-5 std', '-mask')
xlabel('igm index')
ylabel('igm count')
grid on; zoom on
saveas(gcf, 'SW_high_res_imag_igm_stats', 'png')
saveas(gcf, 'SW_high_res_imag_igm_stats', 'fig')

