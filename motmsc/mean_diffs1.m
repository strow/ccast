%
% mean_diffs1 -- compare FOR 15 and FOR 16 runs of mean_cfovs
%

addpath mean_cfovs
addpath ../motmsc/utils
addpath /home/motteler/matlab/export_fig

f1 = input('file 1 > ', 's');
f2 = input('file 2 > ', 's');

d1 = load(f1);
d2 = load(f2);

% concatenate bands
vgrid = [d1.vLW(3:end-2); d1.vMW(3:end-2); d1.vSW(3:end-2)];
d1_bm = [d1.bmLW(3:end-2, :); d1.bmMW(3:end-2, :); d1.bmSW(3:end-2, :)];
d2_bm = [d2.bmLW(3:end-2, :); d2.bmMW(3:end-2, :); d2.bmSW(3:end-2, :)];
d1_am = [d1.amLW(3:end-2, :); d1.amMW(3:end-2, :); d1.amSW(3:end-2, :)];
d2_am = [d2.amLW(3:end-2, :); d2.amMW(3:end-2, :); d2.amSW(3:end-2, :)];

% take differences
mdif = d1_bm - d2_bm;
adif = d1_am - d2_am;

% plot setup
tstr = d1.tstr;
for1 = d1.sFOR;
for2 = d2.sFOR;

% names and colors
fname = fovnames;
fcolor = fovcolors;
pstr = strrep(tstr, '_', '-');

%------------------------
% FOR double differences
%------------------------
figure(1); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(3,1,1)
ix = [1,3,7,9];
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(vgrid, mdif(:, ix) - adif(:, ix));
axis([600, 2600, -0.2, 0.2])
title(sprintf('FOR %d - %d double diff, %s', for1, for2, pstr))
legend(fname{ix}, 'location', 'eastoutside')
ylabel('dBT, K')
grid on; zoom on

subplot(3,1,2)
ix = [2,4,6,8];
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(vgrid, mdif(:, ix) - adif(:, ix));
axis([600, 2600, -0.2, 0.2])
legend(fname{ix}, 'location', 'eastoutside')
ylabel('dBT, K')
grid on; zoom on

subplot(3,1,3)
ix = [5];
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(vgrid, mdif(:, ix) - adif(:, ix));
axis([600, 2600, -0.2, 0.2])
legend(fname{ix}, 'location', 'eastoutside')
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

% pname = sprintf('rel_ddif_%s', tstr);
% saveas(gcf, pname, 'fig')
% export_fig([pname,'.pdf'], '-m2', '-transparent')

return

%------------------------
% FOR single differences
%------------------------
figure(2); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fcolor);
plot(vgrid, mdif);
% axis([pv1, pv2, ymin, ymax])
title(sprintf('FOR %d - %d, test %s', for1, for2, pstr))
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
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(2,1,1)
ix = [9, 3, 6, 5, 2];
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(vgrid, mdif(:, ix));
% axis([pv1, pv2, ymin, ymax])
title(sprintf('FOR %d - %d, scan breakouts', for1, for2))
legend(fname{ix}, 'location', 'eastoutside')
ylabel('dBT, K')
grid on; zoom on

subplot(2,1,2)
ix = [8, 7, 4, 1];
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(vgrid, mdif(:, ix));
% axis([pv1, pv2, ymin, ymax])
legend(fname{ix}, 'location', 'eastoutside')
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

% pname = sprintf('ccast_%s_%s_sbrk_%s', band, tstr);
% saveas(gcf, pname, 'fig')
% export_fig([pname,'.pdf'], '-m2', '-transparent')

