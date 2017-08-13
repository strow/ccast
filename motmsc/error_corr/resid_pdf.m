%
% residual PDFs, run after cal_test3 with all FOVs selected
%

figure(1); clf
subplot(2,1,1)
plot(vobsLW, mean(errLW, 2))
title('obs minus calc mean')
grid on; zoom on
subplot(2,1,2)
title('obs minus calc std')
plot(vobsLW, std(errLW, 0, 2))
grid on; zoom on

v0 = input('freq > ');
jx = interp1(vobsLW, 1:length(vobsLW), v0, 'nearest');
vobsLW(jx)

figure(2); clf
etmp = errLW(jx, :);
histogram(etmp, 40)
title(sprintf('residual PDF %.2f cm-1', vobsLW(jx)));
grid on; hold on

x = -2:0.02:2;
y = normpdf(x, mean(etmp), std(etmp));
y = 310 * y / max(y);
plot(x, y, 'linewidth', 2)
% ax = axis; ax(1) = -2; ax(2) = 2; axis(ax);
hold off


