%
% mean_diffs2 -- compare two FOR 15-16 runs of mean_cfovs
%

addpath mean_cfovs
addpath ../motmsc/utils
addpath /home/motteler/matlab/export_fig

f1 = input('file 1 > ', 's');
f2 = input('file 2 > ', 's');

% f1 = 'ccast_d2_Pn_ag_15-16.mat';
% f2 = 'ccast_e5_Pn_ag_15-16.mat';

d1 = load(f1);
d2 = load(f2);

% concatenate bands
vgrid = [d1.vLW(3:end-2); d1.vMW(3:end-2); d1.vSW(3:end-2)];
bavg1 = [d1.bmLW(3:end-2, :); d1.bmMW(3:end-2, :); d1.bmSW(3:end-2, :)];
bstd1 = [d1.bsLW(3:end-2, :); d1.bsMW(3:end-2, :); d1.bsSW(3:end-2, :)];

vgrid = [d2.vLW(3:end-2); d2.vMW(3:end-2); d2.vSW(3:end-2)];
bavg2 = [d2.bmLW(3:end-2, :); d2.bmMW(3:end-2, :); d2.bmSW(3:end-2, :)];
bstd2 = [d2.bsLW(3:end-2, :); d2.bsMW(3:end-2, :); d2.bsSW(3:end-2, :)];

% relative differences
iref = 5;
bavg_diff1 = bavg1 - bavg1(:, iref) * ones(1, 9);
bstd_diff1 = bstd1 - bstd1(:, iref) * ones(1, 9);

bavg_diff2 = bavg2 - bavg2(:, iref) * ones(1, 9);
bstd_diff2 = bstd2 - bstd2(:, iref) * ones(1, 9);

% plot names and colors
fname = fovnames;
fcolor = fovcolors;

% plot title suffix
tstr1 = d1.tstr; tstr2 = d2.tstr;
% tstr1 = 'noaa'; tstr2 = 'ccast';
pstr1 = strrep(tstr1, '_', '-');
pstr2 = strrep(tstr2, '_', '-');

%---------------------
% three-band overview 
%---------------------

figure(1); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(3,1,1)
set(gcf, 'DefaultAxesColorOrder', fcolor);
plot(vgrid, bavg_diff1);
axis([650, 2550, -1, 1])
title(sprintf('%s 3-day test, all FOVs minus FOV %d', pstr1, iref))
ylabel('dBT, K')
grid on; zoom on

subplot(3,1,2)
set(gcf, 'DefaultAxesColorOrder', fcolor);
plot(vgrid, bavg_diff2);
axis([650, 2550, -1, 1])
title(sprintf('%s 3-day test, all FOVs minus FOV %d', pstr2, iref))
ylabel('dBT, K')
grid on; zoom on

subplot(3,1,3)
set(gcf, 'DefaultAxesColorOrder', fcolor);
plot(vgrid, bavg_diff2 - bavg_diff1);
axis([650, 2550, -0.3, 0.3])
title(sprintf('%s minus %s 3-day test, all FOVs', pstr2, pstr1))
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

% saveas(gcf, 'rel_summary', 'png')
% export_fig('rel_summary.pdf', '-m2', '-transparent')

