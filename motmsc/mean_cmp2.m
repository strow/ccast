%
% mean_cmp2 -- compare ccast and noaa mean stats
% 

addpath /asl/matlib/fileexchange/export_fig

% load data from mean_cfovs and mean_ifovs
ccast = load('ccast_MW_2014_340-342_hr.mat');
noaa  = load('noaa_MW_2014_340-342.mat');     

% basic test params
user = ccast.user;
band = ccast.band;
vgrid = ccast.vgrid;

% single and double differences
b1dif = ccast.bavg - noaa.bavg;
b2dif = ccast.bavg_diff - noaa.bavg_diff;

% plot names and colors
fname = fovnames;
fcolor = fovcolors;

% plot frequency span
pv1 = 10 * floor(user.v1 / 10);
pv2 = 10 *  ceil(user.v2 / 10);

%-----------------------------------
% single FOV spectra and difference
%-----------------------------------
figure(1); clf
subplot(3,1,1)
ifov = 1;
plot(vgrid, b1dif(:, ifov))
ax = axis; ax(1) = pv1; ax(2) = pv2; axis(ax)
% xlabel('wavenumber')
ylabel('BT, K')
title(sprintf('ccast minus noaa %s FOV %d', ccast.band, ifov))
grid on; zoom on

subplot(3,1,2)
ifov = 2;
plot(vgrid, b1dif(:, ifov))
ax = axis; ax(1) = pv1; ax(2) = pv2; axis(ax)
% xlabel('wavenumber')
ylabel('BT, K')
title(sprintf('ccast minus noaa %s FOV %d', ccast.band, ifov))
grid on; zoom on
 
subplot(3,1,3)
ifov = 5;
plot(vgrid, b1dif(:, ifov))
ax = axis; ax(1) = pv1; ax(2) = pv2; axis(ax)
xlabel('wavenumber')
ylabel('dBT, K')
title(sprintf('ccast minus noaa %s FOV %d', ccast.band, ifov))
grid on; zoom on

pname = sprintf('ccast_noaa_%s_fig_1', band);
export_fig([pname,'.pdf'], '-m2', '-transparent')

%----------------------------
% single difference breakout
%----------------------------
figure(2); clf
subplot(2,1,1)
ix = [1 3 7 9];
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(vgrid, b1dif(:, ix))
ax = axis; ax(1) = pv1; ax(2) = pv2; axis(ax)
% xlabel('wavenumber')
ylabel('dBT, K')
title(sprintf('%s ccast - noaa mean, corner FOVs', ccast.band))
legend(fname{ix}, 'location', 'eastoutside')
grid on; zoom on
 
subplot(2,1,2)
ix = [2 4 6 8];
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(vgrid, b1dif(:, ix))
ax = axis; ax(1) = pv1; ax(2) = pv2; axis(ax)
xlabel('wavenumber')
ylabel('dBT, K')
title(sprintf('%s ccast - noaa mean, side FOVs', ccast.band))
legend(fname{ix}, 'location', 'eastoutside')
grid on; zoom on

pname = sprintf('ccast_noaa_%s_fig_2', band);
export_fig([pname,'.pdf'], '-m2', '-transparent')

%----------------------------
% double difference breakout
%----------------------------
figure(3); clf
subplot(2,1,1)
ix = [1 3 7 9];
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(vgrid, b2dif(:, ix))
ax = axis; ax(1) = pv1; ax(2) = pv2; axis(ax)
% xlabel('wavenumber')
ylabel('dBT, K')
title(sprintf('%s ccast - noaa relative, corner FOVs', ccast.band))
legend(fname{ix}, 'location', 'eastoutside')
grid on; zoom on
 
subplot(2,1,2)
ix = [2 4 6 8];
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(vgrid, b2dif(:, ix))
ax = axis; ax(1) = pv1; ax(2) = pv2; axis(ax)
xlabel('wavenumber')
ylabel('dBT, K')
title(sprintf('%s ccast - noaa relative, side FOVs', ccast.band))
legend(fname{ix}, 'location', 'eastoutside')
grid on; zoom on

pname = sprintf('ccast_noaa_%s_fig_3', band);
export_fig([pname,'.pdf'], '-m2', '-transparent')

