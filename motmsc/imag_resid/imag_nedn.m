% 
% imag_nedn - plot complex residuals and NEdN from imag_stats3
%

% load imag_stats_t13  % high res test
% load imag_stats_t16  % low res test
  load imag_300K       % test above 300K

figure(1)
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
ifov = [1 3 5];
for i = 1 : 3
  subplot(3,1,i)
  plot(vLW, csLW(:, ifov(i)), vLW, nmLW(:, ifov(i)))
% axis([650, 1100, 0, 0.4])
  axis([650, 1100, 0.05, 0.15])
  title(sprintf('FOV %d LW complex residual std and NEdN', ifov(i)))
  legend('standard dev', 'mean NEdN', 'location', 'north')
  ylabel('radiance')
  grid on; zoom on
end
xlabel('wavenumber')
% saveas(gcf, 'NEdN_resid_LW', 'png')

figure(2)
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
ifov = [1 5 7];
for i = 1 : 3
  subplot(3,1,i)
  plot(vMW, csMW(:, ifov(i)), vMW, nmMW(:, ifov(i)))
  axis([1200, 1750, 0, 0.2])
  title(sprintf('FOV %d MW complex residual std and NEdN', ifov(i)))
  legend('standard dev', 'mean NEdN', 'location', 'north')
  ylabel('radiance')
  grid on; zoom on
end
xlabel('wavenumber')
% saveas(gcf, 'NEdN_resid_MW', 'png')

figure(3)
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
ifov = [1 3 5];
for i = 1 : 3
  subplot(3,1,i)
  plot(vSW, csSW(:, ifov(i)), vSW, nmSW(:, ifov(i)))
  axis([2150, 2550, 4e-3, 14e-3])
% axis([2150, 2550, 2e-3, 5e-3])
  title(sprintf('FOV %d SW complex residual std and NEdN', ifov(i)))
  legend('standard dev', 'mean NEdN', 'location', 'north')
  ylabel('radiance')
  grid on; zoom on
end
xlabel('wavenumber')
% saveas(gcf, 'NEdN_resid_SW', 'png')

