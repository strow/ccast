%
% mean_plots -- plot results from mean_cfovs
%

addpath ../motmsc/utils
addpath /home/motteler/matlab/export_fig

%---------------------
% three-band overview 
%---------------------

file = input('file > ', 's');
load(file);

% concatenate bands
vgrid = [vLW(3:end-2); vMW(3:end-2); vSW(3:end-2)];
bavg = [bmLW(3:end-2, :); bmMW(3:end-2, :); bmSW(3:end-2, :)];
bstd = [bsLW(3:end-2, :); bsMW(3:end-2, :); bsSW(3:end-2, :)];

% relative differences
iref = 5;
bavg_diff = bavg - bavg(:, iref) * ones(1, 9);
bstd_diff = bstd - bstd(:, iref) * ones(1, 9);

% plot names and colors
fname = fovnames;
fcolor = fovcolors;

% plot title suffix
pstr = strrep(tstr, '_', '-');

figure(1); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(2,1,1)
ix = [1,3,7,9];
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(vgrid, bavg_diff(:, ix));
axis([650, 2550, -1, 2])
legend(fname{ix}, 'location', 'north')
title(sprintf('corner FOVs minus FOV %d, test %s', iref, pstr))
% xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

subplot(2,1,2)
ix = [2,4,6,8];
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(vgrid, bavg_diff(:, ix));
axis([650, 2550, -1, 2])
legend(fname{ix}, 'location', 'north')
title(sprintf('side FOVs minus FOV %d', iref))
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

%-----------------------
% plot individual bands
%-----------------------

band = input('band > ', 's');
switch band
  case 'LW', bavg = bmLW; bstd = bsLW; bn = bnLW; vgrid = vLW; user = userLW;
  case 'MW', bavg = bmMW; bstd = bsMW; bn = bnMW; vgrid = vMW; user = userMW;
  case 'SW', bavg = bmSW; bstd = bsSW; bn = bnSW; vgrid = vSW; user = userSW;
  otherwise return
end

% case 'LW', bavg = amLW; bstd = asLW; bn = bnLW; vgrid = vLW; user = userLW;
% case 'MW', bavg = amMW; bstd = asMW; bn = bnMW; vgrid = vMW; user = userMW;
% case 'SW', bavg = amSW; bstd = asSW; bn = bnSW; vgrid = vSW; user = userSW;

% get relative differences
bavg_diff = bavg - bavg(:, iref) * ones(1, 9);
bstd_diff = bstd - bstd(:, iref) * ones(1, 9);

% print some stats
fprintf(1, 'residuals by FOV\n')
fprintf(1, '%8.4f', rms(bavg_diff))
fprintf(1, '\nccast %s FOV %d, test %s, bn = %d\n', band, iref, tstr, bn)

% plot frequency grid
pv1 = 10 * floor(user.v1 / 10);
pv2 = 10 *  ceil(user.v2 / 10);

% residual plot range
switch band
  case 'LW', amin = -0.4; amax =  0.4; smin = -0.4; smax =  0.4;
  case 'MW', amin = -0.8; amax =  0.8; smin = -0.4; smax =  2.0;
  case 'SW', amin = -1.2; amax =  2.8; smin = -2.0; smax =  2.0;
end

%----------------------------
% means and means minus ifov
%----------------------------
figure(2); clf
set(gcf, 'DefaultAxesColorOrder', fcolor);
subplot(2,1,1)
plot(vgrid, bavg);
ax = axis; ax(1) = pv1; ax(2) = pv2; axis(ax);
legend(fname, 'location', 'eastoutside')
title(sprintf('%s mean, all FOVs, test %s', band, pstr))
% xlabel('wavenumber')
ylabel('BT, K')
grid on; zoom on

subplot(2,1,2)
plot(vgrid, bavg_diff);
axis([pv1, pv2, amin, amax])
legend(fname, 'location', 'eastoutside')
title(sprintf('all FOVs minus FOV %d', iref))
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

% pname = sprintf('ccast_%s_avg_%s', band, tstr);
% saveas(gcf, pname, 'fig')
% export_fig([pname,'.pdf'], '-m2', '-transparent')

%-------------------------------
% corner and side FOV breakouts
%-------------------------------
figure(3); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(2,1,1)
ix = [1,3,7,9];
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(vgrid, bavg_diff(:, ix));
axis([pv1, pv2, amin, amax])
legend(fname{ix}, 'location', 'eastoutside')
title(sprintf('%s corner FOVs minus FOV %d, test %s', band, iref, pstr))
% xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

subplot(2,1,2)
ix = [2,4,6,8];
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(vgrid, bavg_diff(:, ix));
axis([pv1, pv2, amin, amax])
legend(fname{ix}, 'location', 'eastoutside')
title(sprintf('side FOVs minus FOV %d', iref))
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

% pname = sprintf('ccast_%s_dif_%s', pband, tstr);
% saveas(gcf, pname, 'fig')
% export_fig([pname,'.pdf'], '-m2', '-transparent')

%--------------------------
% stds and stds minus ifov
%--------------------------
figure(4); clf
set(gcf, 'DefaultAxesColorOrder', fcolor);
subplot(2,1,1)
plot(vgrid, bstd);
ax = axis; ax(1) = pv1; ax(2) = pv2; axis(ax);
legend(fname, 'location', 'eastoutside')
title(sprintf('%s std, all FOVs, test %s', band, pstr))
% xlabel('wavenumber')
ylabel('BT, K')
grid on; zoom on

subplot(2,1,2)
plot(vgrid, bstd_diff)
axis([pv1, pv2, smin, smax])
legend(fname, 'location', 'eastoutside')
title(sprintf('all FOVs minus FOV %d', iref))
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

% pname = sprintf('ccast_%s_std_%s', band, tstr);
% saveas(gcf, pname, 'fig')
% export_fig([pname,'.pdf'], '-m2', '-transparent')

