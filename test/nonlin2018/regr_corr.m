%
% quick test of applying a regression corrections to nonlinear FOVs
%

addpath ../motmsc/utils

tset1 = 'a2_set2_1/a2v3_ref.mat';
tset2 = 'a2_set2_3/a2v3_ref.mat';

d1 = load(tset1);
d2 = load(tset2);
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

% frequency fit interval
ixLW =  700 <= vLW & vLW <= 1000;
ixMW = 1250 <= vMW & vMW <= 1700;

pLW = polyfit(bLW1(ixLW,5), refLW1(ixLW), 2);
pMW = polyfit(bMW1(ixMW,9), refMW1(ixMW), 2);

corLW1 = polyval(pLW, bLW1(:,5));
corMW1 = polyval(pMW, bMW1(:,9));

corLW2 = polyval(pLW, bLW2(:,5));
corMW2 = polyval(pMW, bMW2(:,9));

figure(1)
subplot(2,1,1)
plot(vLW, bLW1(:,5) - refLW1, vLW, corLW1 - refLW1)
axis([650, 1100, -0.2, 0.2])
title('LW FOV 5 dependent set')
legend('init - ref', 'corr - ref', 'location', 'south')
ylabel('dTb, K')
grid on

subplot(2,1,2)
plot(vLW, bLW2(:,5) - refLW2, vLW, corLW2 - refLW2)
axis([650, 1100, -0.2, 0.2])
title('LW FOV 5 dependent set')
legend('init - ref', 'corr - ref', 'location', 'south')
xlabel('wavenumber, cm-1')
ylabel('dTb, K')
grid on

figure(2)
subplot(2,1,1)
plot(vMW, bMW1(:,9) - refMW1, vMW, corMW1 - refMW1)
axis([1200, 1760, -0.2, 1.0])
title('MW FOV 9 dependent set')
legend('init - ref', 'corr - ref', 'location', 'northwest')
ylabel('dTb, K')
grid on

subplot(2,1,2)
plot(vMW, bMW2(:,9) - refMW2, vMW, corMW2 - refMW2)
axis([1200, 1760, -0.2, 1.0])
title('MW FOV 9 independent set')
legend('init - ref', 'corr - ref', 'location', 'northwest')
xlabel('wavenumber, cm-1')
ylabel('dTb, K')
grid on

