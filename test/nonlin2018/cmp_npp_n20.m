%
% compare NPP and N20 means
%

addpath ../source
addpath ../motmsc/utils
addpath ../test/nonlin2018
addpath /asl/packages/airs_decon/source

tdir = 'npp_n20_54-85_1';

d1 = load(fullfile(tdir, 'npp_mean'));
d2 = load(fullfile(tdir, 'n20_mean'));

vLW = d1.vLW;
vMW = d1.vMW;
bLW1 = d1.mLW;
bLW2 = d2.mLW;
bMW1 = d1.mMW;
bMW2 = d2.mMW;

% rLW1 = bt2rad(vLW, d1.mLW);
% rLW2 = bt2rad(vLW, d2.mLW);
% rMW1 = bt2rad(vMW, d1.mMW);
% rMW2 = bt2rad(vMW, d2.mMW);
% bLW1 = rad2bt(vLW, hamm_app(rLW1));
% bLW2 = rad2bt(vLW, hamm_app(rLW2));
% bMW1 = rad2bt(vMW, hamm_app(rMW1));
% bMW2 = rad2bt(vMW, hamm_app(rMW2));

% --- LW mean comparison plot ---
figure(1); clf
  set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(vLW, bLW1 - bLW2)
axis([650, 1100, -0.2, 0.15])
title('LW NPP minus N20, 2018 doy 54-85')
legend(fovnames, 'location', 'south')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on
  saveas(gcf, 'LW_NPP_minus_N20_all_FOR_doy_54-85', 'png')

% --- MW comparison plot ---
figure(2); clf
  set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(vMW, bMW1 - bMW2)
axis([1200, 1760, -0.3, 0.2])
title('MW NPP minus N20, 2018 doy 54-85')
legend(fovnames, 'location', 'south')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on
  saveas(gcf, 'MW_NPP_minus_N20_all_FOR_doy_54-85', 'png')

return

% --- MW detail ---
figure(3); clf
fc = fovcolors;
  set(gcf, 'DefaultAxesColorOrder', fc([7, 9], :));
% set(gcf, 'DefaultAxesColorOrder', fovcolors);
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
yy = bMW1 - bMW2;
plot(vMW, yy(:, 7), vMW, yy(:, 9))
axis([1200, 1760, -0.3, 0.25])
title('MW NPP minus N20 detail')
legend('FOV 7', 'FOV 9', 'location', 'southwest')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on
% saveas(gcf, 'MW_NPP_minus_N20_detail', 'png')

