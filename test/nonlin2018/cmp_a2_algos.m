%
% compare UW NPP and UMBC ATBD nonlinearity correction algorithms
%

addpath ../motmsc/utils
addpath ../source

d1 = load('a2v4_set_1/a2v4_ref');
d2 = load('atbd_set_1/atbd_ref');

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

sLW1 = d1.sLW;
sLW2 = d2.sLW;
srefLW1 = (sLW1(:,6) + sLW1(:,7) + sLW1(:,9)) / 3;
srefLW2 = (sLW2(:,6) + sLW2(:,7) + sLW2(:,9)) / 3;

% --- LW mean comparison plot ---
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
title('LW all FOVs minus ref, ATBD, UMBC v1 weights')
legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on
% saveas(gcf, 'nonlin_cmp_LW_2', 'fig')

% --- MW comparison plot ---
figure(2); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
subplot(2,1,1)
plot(vMW, bMW1 - refMW1)
s = 0.3;
axis([1200, 1760, -s, s])
title('MW all FOVs minus ref, UW NPP, a2v4 weights')
legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on

subplot(2,1,2)
plot(vMW, bMW2 - refMW2)
axis([1200, 1760, -s, s])
title('MW all FOVs minus ref, ATBD, UMBC v1 weights')
legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on
% saveas(gcf, 'nonlin_cmp_MW_2', 'fig')

return

% --- LW std comparison plot ---
figure(3); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
subplot(2,1,1)
plot(vLW, sLW1 - srefLW1)
s = 0.1;
axis([650, 1100, -s, s])
title('LW std all FOVs minus ref, UW NPP, a2v4 weights')
legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on

subplot(2,1,2)
plot(vLW, sLW2 - srefLW2)
axis([650, 1100, -s, s])
title('LW std all FOVs minus ref, ATBD, UMBC v1 weights')
legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on
% saveas(gcf, 'nonlin_cmp_LW_2', 'fig')

