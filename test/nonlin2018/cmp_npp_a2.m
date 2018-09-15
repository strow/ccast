%
% compare UW and UMBC NPP a2 values
%

addpath ../source
addpath ../motmsc/utils
addpath ../test/nonlin2018
addpath /asl/packages/airs_decon/source

  tdir = 'npp_15-30_1';
% tdir = 'npp_31-46_2';

d1 = load(fullfile(tdir, 'npp_umbc'));
d2 = load(fullfile(tdir, 'npp_uwa2'));

vLW = d1.vLW;
vMW = d1.vMW;
bLW1 = hamm_app(d1.mLW);
bMW1 =  hamm_app(d1.mMW);
bLW2 =  hamm_app(d2.mLW);
bMW2 =  hamm_app(d2.mMW);

% refLW1 = bLW1(:,5);
% refLW2 = bLW2(:,5);
% refMW1 = bMW1(:,5);
% refMW2 = bMW2(:,5);

% refLW1 = (bLW1(:,2) + bLW1(:,5)) / 2;
% refLW2 = (bLW2(:,2) + bLW2(:,5)) / 2;
% refMW1 = (bMW1(:,6) + bMW1(:,9)) / 2;
% refMW2 = (bMW2(:,6) + bMW2(:,9)) / 2;

refLW1 = (bLW1(:,2) + bLW1(:,5) + bLW1(:,7)) / 3;
refLW2 = (bLW2(:,2) + bLW2(:,5) + bLW2(:,7)) / 3;
refMW1 = (bMW1(:,1) + bMW1(:,6) + bMW1(:,9)) / 3;
refMW2 = (bMW2(:,1) + bMW2(:,6) + bMW2(:,9)) / 3;

% --- LW mean comparison plot ---
figure(1); clf
  set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
subplot(2,1,1)
plot(vLW, bLW1 - refLW1)
s = 0.2;
axis([650, 1100, -s, s])
title('LW all FOVs minus ref, UMBC 2016 weights')
legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on

subplot(2,1,2)
plot(vLW, bLW2 - refLW2)
axis([650, 1100, -s, s])
title('LW all FOVs minus ref, UW 2013 weights')
legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on
  saveas(gcf, 'NPP_LW_16-day_a2', 'png')

% --- MW comparison plot ---
figure(2); clf
  set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
subplot(2,1,1)
plot(vMW, bMW1 - refMW1)
s = 0.3;
axis([1200, 1760, -s, s])
title('MW all FOVs minus ref, UMBC 2016 weights')
legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on

subplot(2,1,2)
plot(vMW, bMW2 - refMW2)
axis([1200, 1760, -s, s])
title('MW all FOVs minus ref, UW MW alt weights')
legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on
  saveas(gcf, 'NPP_MW_16-day_a2', 'png')

% return

% UW 2013 a2 values with modificed MW FOV 7
UWa2LW = ...
  [0.01936 0.01433 0.01609 0.02192 0.01341 0.01637 0.01464 0.01732 0.03045];
UWa2MW = ...
  [0.00529 0.02156 0.02924 0.01215 0.01435 0.00372 0.09418 0.04564 0.00256];

% UMBC 2016 NPP a2 values
UMBCa2LW = [0.0175 0.0122 0.0137 0.0219 0.0114 0.0164 0.0124 0.0164 0.0305];
UMBCa2MW = [0.0016 0.0173 0.0263 0.0079 0.0093 0.0015 0.0963 0.0410 0.0016];

figure(3); clf
subplot(2,1,1)
bar([UWa2LW', UMBCa2LW'])
title('NPP LW a2 weights')
legend('UMBC 2016', 'UW 2013 eng', 'location', 'northwest')
% xlabel('FOV')
ylabel('weight')
grid on

subplot(2,1,2)
bar([UWa2MW', UMBCa2MW'])
title('NPP MW a2 weights')
legend('UMBC 2016', 'UW 2013 rev.', 'location', 'northwest')
xlabel('FOV')
ylabel('weight')
grid on
saveas(gcf, 'current_NPP_a2_values', 'png')
