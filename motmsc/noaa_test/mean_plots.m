%
% mean_plots -- plot results from mean_cfovs and mean_ifovs
%

addpath ../motmsc/utils
addpath /home/motteler/matlab/export_fig

% names and colors
fname = fovnames;
fcolor = fovcolors;

% plot frequency grid
pv1 = 10 * floor(user.v1 / 10);
pv2 = 10 *  ceil(user.v2 / 10);

% residual plot range
switch band
  case 'LW', amin = -0.4; amax =  0.4; smin = -0.4; smax =  0.4;
  case 'MW', amin = -0.8; amax =  0.8; smin = -0.4; smax =  2.0;
  case 'SW', amin = -1.2; amax =  2.8; smin = -2.0; smax =  2.0;
end

% processing string
if ~isempty(strfind(syear, 'ccast')), proc = 'ccast'; 
else, proc = 'noaa'; end

% plot title suffix
pstr = strrep(tstr, '_', ' ');

%---------------------------------
% plot means and means minus ifov
%---------------------------------
figure(1); clf
set(gcf, 'DefaultAxesColorOrder', fcolor);
subplot(2,1,1)
plot(vgrid, bavg);
ax = axis; ax(1) = pv1; ax(2) = pv2; axis(ax);
legend(fname, 'location', 'eastoutside')
title(sprintf('%s %s mean, all FOVs, test %s', proc, band, pstr))
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

pname = sprintf('%s_%s_avg_%s', proc, band, tstr);
% saveas(gcf, pname, 'fig')
% export_fig([pname,'.pdf'], '-m2', '-transparent')

%-------------------------------
% corner and side FOV breakouts
%-------------------------------
figure(2); clf
subplot(2,1,1)
ix = [1,3,7,9];
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(vgrid, bavg_diff(:, ix));
axis([pv1, pv2, amin, amax])
legend(fname{ix}, 'location', 'eastoutside')
title(sprintf('%s %s corner FOVs minus FOV %d, test %s', proc, band, iref, pstr))
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

pname = sprintf('%s_%s_dif_%s', proc, band, tstr);
% saveas(gcf, pname, 'fig')
% export_fig([pname,'.pdf'], '-m2', '-transparent')

return

%-------------------------------
% plot stds and stds minus ifov
%-------------------------------
figure(3); clf
set(gcf, 'DefaultAxesColorOrder', fcolor);
subplot(2,1,1)
plot(vgrid, bstd);
ax = axis; ax(1) = pv1; ax(2) = pv2; axis(ax);
legend(fname, 'location', 'eastoutside')
title(sprintf('%s %s std, all FOVs, test %s', proc, band, pstr))
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

pname = sprintf('%s_%s_std_%s', proc, band, tstr);
% saveas(gcf, pname, 'fig')
% export_fig([pname,'.pdf'], '-m2', '-transparent')

