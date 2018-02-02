%
% compare UW NPP (old) and ATBD (new) nonlinearity algorithms using
% the same set of UW weights
%

d1 = load('a2_algo_3/a2v4_old');
d2 = load('a2_algo_3/a2v4_new');

vLW = d1.vLW;
vMW = d1.vMW;
bLW1 = d1.mLW;
bMW1 = d1.mMW;
bLW2 = d2.mLW;
bMW2 = d2.mMW;

refLW1 = (bLW1(:,6) + bLW1(:,7) + bLW1(:,9)) / 3;
refLW2 = (bLW2(:,6) + bLW2(:,7) + bLW2(:,9)) / 3;

refMW1 = mean(bMW1(:,1:8),2);
refMW2 = mean(bMW2(:,1:8),2);

% --- LW comparison plot ---
figure(1); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
subplot(2,1,1)
plot(vLW, bLW1 - refLW1)
s = 0.3;
axis([650, 1100, -s, s])
title('LW all FOVs minus ref, UW NPP, a2v4 weights')
legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on

subplot(2,1,2)
plot(vLW, bLW2 - refLW2)
axis([650, 1100, -s, s])
title('LW all FOVs minus ref, ATBD, a2v4 weights')
legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on

% --- MW comparison plot ---
figure(2); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
subplot(2,1,1)
plot(vMW, bMW1 - refMW1)
axis([1200, 1760, -0.6, 1.2])
title('MW all FOVs minus ref, UW NPP, a2v4 weights')
legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on

subplot(2,1,2)
plot(vMW, bMW2 - refMW2)
axis([1200, 1760, -0.6, 1.2])
title('MW all FOVs minus ref, ATBD, a2v4 weights')
legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on

