
d0 = load('cal_test4_000');
d3 = load('cal_test4_003');
d5 = load('cal_test4_005');
d7 = load('cal_test4_007');
dx = load('cal_test4_bcal');

j = 7;
figure(1); clf
subplot(3,1,1)
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
plot(d0.vobsMW, d0.ddifMW(:, j), 'k', ...
     d3.vobsMW, d3.ddifMW(:, j), ...
     d5.vobsMW, d5.ddifMW(:, j), ...
     d7.vobsMW, d7.ddifMW(:, j), 'linewidth', 2);
  axis([1325, 1345, -0.15 0.35])
% axis([1720, 1750, -0.9, 0.7])
title('double difference by quadratic term weight')
legend('0.00', '0.03', '0.05', '0.07', 'location', 'northwest')
% xlabel('wavenumber')
ylabel('ddTb, K')
grid on; zoom on
% saveas(gcf, 'ddif_by_wt', 'png')

% figure(2); clf
subplot(3,1,2)
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
plot(d0.vobsMW, d0.resMW(:, j), 'k', ...
     d3.vobsMW, d3.resMW(:, j), ...
     d5.vobsMW, d5.resMW(:, j), ...
     d7.vobsMW, d7.resMW(:, j), 'linewidth', 2);
  axis([1325, 1345, -1.5, 1.0])
% axis([1720, 1750, -1.0, 2.0])
title('residuals by quadratic term weight')
legend('0.00', '0.03', '0.05', '0.07', 'location', 'southwest')
% xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on
% saveas(gcf, 'resid_by_wt', 'png')

% figure(3); clf
subplot(3,1,3)
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
plot(d0.vobsMW, dx.bcalMW(:, j), 'k', 'linewidth', 2)
  axis([1325, 1345, 210, 290])
% axis([1720, 1750, 210, 260])
title('expected spectra')
xlabel('wavenumber')
ylabel('Tb, K')
grid on; zoom on
% saveas(gcf, 'resid_by_wt', 'png')

t1 = [rms(d0.resMW)', rms(d3.resMW)', rms(d5.resMW)', rms(d7.resMW)'];
t2 = [rms(d0.ddifMW)', rms(d3.ddifMW)', rms(d5.ddifMW)', rms(d7.ddifMW)'];

[ (t1(j,2) - t1(j,1)) / t1(j,1), ...
  (t1(j,3) - t1(j,1)) / t1(j,1), ...
  (t1(j,4) - t1(j,1)) / t1(j,1)]

[ (t2(j,2) - t2(j,1)) / t2(j,1), ...
  (t2(j,3) - t2(j,1)) / t2(j,1), ...
  (t2(j,4) - t2(j,1)) / t2(j,1)]

