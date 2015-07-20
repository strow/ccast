%
% mean_diffs -- compare two runs of mean_cfovs
%

addpath ../motmsc/utils
addpath /home/motteler/matlab/export_fig

f1 = input('file 1 > ', 's');
f2 = input('file 2 > ', 's');

d1 = load(f1);
d2 = load(f2);

band = input('band > ', 's');

switch band
  case 'LW'
    mdif = d1.bmLW - d2.bmLW; vgrid = d1.vLW; 
    adif = d1.amLW - d2.amLW; user  = d1.userLW;
  case 'MW'
    mdif = d1.bmMW - d2.bmMW; vgrid = d1.vMW; 
    adif = d1.amMW - d2.amMW; user  = d1.userMW;
  case 'SW'
    mdif = d1.bmSW - d2.bmSW; vgrid = d1.vSW; 
    adif = d1.amSW - d2.amSW; user  = d1.userSW;
end

tstr = d1.tstr;
for1 = d1.sFOR;
for2 = d2.sFOR;

% names and colors
fname = fovnames;
fcolor = fovcolors;

% plot frequency grid
pv1 = 10 * floor(user.v1 / 10);
pv2 = 10 *  ceil(user.v2 / 10);

% plot title suffix
pstr = strrep(tstr, '_', '-');

%------------------------
% FOR double differences
%------------------------
switch band
  case 'LW', ymin = -0.1; ymax =  0.1;
  case 'MW', ymin = -0.2; ymax =  0.2;
  case 'SW', ymin = -0.3; ymax =  0.3;
end
figure(1); clf
subplot(3,1,1)
ix = [1,3,7,9];
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(vgrid, mdif(:, ix) - adif(:, ix));
axis([pv1, pv2, ymin, ymax])
title(sprintf('%s FOR %d - %d double diff, %s', band, for1, for2, pstr))
legend(fname{ix}, 'location', 'eastoutside')
ylabel('dBT, K')
grid on; zoom on

subplot(3,1,2)
ix = [2,4,6,8];
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(vgrid, mdif(:, ix) - adif(:, ix));
axis([pv1, pv2, ymin, ymax])
legend(fname{ix}, 'location', 'eastoutside')
ylabel('dBT, K')
grid on; zoom on

subplot(3,1,3)
ix = [5];
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(vgrid, mdif(:, ix) - adif(:, ix));
axis([pv1, pv2, ymin, ymax])
legend(fname{ix}, 'location', 'eastoutside')
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

% pname = sprintf('ccast_%s_sfil_%s', band, tstr);
% saveas(gcf, pname, 'fig')
% export_fig([pname,'.pdf'], '-m2', '-transparent')

%------------------------
% FOR single differences
%------------------------
switch band
  case 'LW', ymin = -0.3; ymax =  0.3;
  case 'MW', ymin = -0.2; ymax =  0.2;
  case 'SW', ymin = -0.4; ymax =  0.6;
end
figure(2); clf
set(gcf, 'DefaultAxesColorOrder', fcolor);
plot(vgrid, mdif);
axis([pv1, pv2, ymin, ymax])
title(sprintf('%s FOR %d - %d, test %s', band, for1, for2, pstr))
legend(fname, 'location', 'eastoutside')
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

% pname = sprintf('ccast_%s_sdif_%s', band, tstr);
% saveas(gcf, pname, 'fig')
% export_fig([pname,'.pdf'], '-m2', '-transparent')

%-----------------------------
% breakouts by scan geometery
%-----------------------------
figure(3); clf
subplot(2,1,1)
ix = [9, 3, 6, 5, 2];
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(vgrid, mdif(:, ix));
axis([pv1, pv2, ymin, ymax])
title(sprintf('%s FOR %d - %d, scan breakouts', band, for1, for2))
legend(fname{ix}, 'location', 'eastoutside')
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

subplot(2,1,2)
ix = [8, 7, 4, 1];
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(vgrid, mdif(:, ix));
axis([pv1, pv2, ymin, ymax])
legend(fname{ix}, 'location', 'eastoutside')
ylabel('dBT, K')
grid on; zoom on

% pname = sprintf('ccast_%s_%s_sbrk_%s', band, tstr);
% saveas(gcf, pname, 'fig')
% export_fig([pname,'.pdf'], '-m2', '-transparent')

