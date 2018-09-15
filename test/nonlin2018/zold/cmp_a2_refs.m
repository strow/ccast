%
% compare LW reference values for an a2 test set
%

addpath ../motmsc/utils

d1 = load('a2_set2_1/a2v3_ref.mat');
d2 = load('a2_set2_2/a2v3_ref.mat');
d3 = load('a2_set2_3/a2v3_ref.mat');
d4 = load('a2_set2_4/a2v3_ref.mat');

b1 = d1.mLW;
b2 = d2.mLW;
b3 = d3.mLW;
b4 = d4.mLW;

bref1 = (b1(:,6) + b1(:,7) + b1(:,9)) ./ 3;
bref2 = (b2(:,6) + b2(:,7) + b2(:,9)) ./ 3;
bref3 = (b3(:,6) + b3(:,7) + b3(:,9)) ./ 3;
bref4 = (b4(:,6) + b4(:,7) + b4(:,9)) ./ 3;

bmean = (bref1 + bref2 + bref3 + bref4) ./ 4;

frq = d1.vLW;

figure(1); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
% set(gcf, 'DefaultAxesColorOrder', fovcolors);
subplot(2,1,1)
plot(frq, bref1, frq, bref2, frq, bref3, frq, bref4);
axis([650, 1100, 210, 280])
title('reference set comparisons')
legend('set 1', 'set 2', 'set 3', 'set 4', 'location', 'south')
% xlabel('wavenumber')
ylabel('Tb, K')
grid on; zoom on

subplot(2,1,2)
plot(frq, bref1 - bmean, frq, bref2 - bmean, ...
     frq, bref3 - bmean, frq, bref4 - bmean);
axis([650, 1100, -0.024, 0.024])
title('reference sets minus reference set mean')
legend('set 1', 'set 2', 'set 3', 'set 4', 'location', 'south')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on
% saveas(gcf, 'ref_set_comparison', 'png')

