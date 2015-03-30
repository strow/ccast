%
% mean_difs -- compare two runs of mean_cfovs
%

addpath /asl/matlib/fileexchange/export_fig

d1 = load('ccast_LW_2015_48-50_hr_15.mat');
d2 = load('ccast_LW_2015_48-50_hr_16.mat');

% shared fields
user  = d1.user;
syear = d1.syear;
tstr  = d1.tstr;
band  = d1.band;
vgrid = d1.vgrid;

% plot content
adif = d1.bavg - d2.bavg;
gdif = gauss_filt(adif);

for1 = d1.sFOR;
for2 = d2.sFOR;

% names and colors
fname = fovnames;
fcolor = fovcolors;

% plot frequency grid
pv1 = 10 * floor(user.v1 / 10);
pv2 = 10 *  ceil(user.v2 / 10);

% residual plot range
switch band
  case 'LW', amin = -0.4; amax =  0.4; bmin = -0.2; bmax =  0.2;
  case 'MW', amin = -0.8; amax =  0.8; bmin = -0.8; bmax =  0.8;
  case 'SW', amin = -1.2; amax =  2.8; bmin = -1.2; bmax =  2.8;
end

% processing string
if ~isempty(strfind(syear, 'ccast')), proc = 'ccast'; 
else, proc = 'noaa'; end

% plot title suffix
pstr = strrep(tstr, '_', ' ');

%------------------------------
% FOV mean FOR diffs, all FOVs
%------------------------------
figure(1); clf
set(gcf, 'DefaultAxesColorOrder', fcolor);
plot(vgrid, adif);
axis([pv1, pv2, amin, amax])
title(sprintf('%s %s FOR %d - %d, test %s', proc, band, for1, for2, pstr))
legend(fname, 'location', 'north')
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

%-------------------------------
% FOV mean FOR diffs, breakouts
%-------------------------------
figure(2); clf
subplot(2,1,1)
ix = [8, 7, 4, 1];
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(vgrid, adif(:, ix));
axis([pv1, pv2, bmin, bmax])
title(sprintf('%s %s FOR %d - %d, breakouts', proc, band, for1, for2))
legend(fname{ix}, 'location', 'eastoutside')
ylabel('dBT, K')
grid on; zoom on

subplot(2,1,2)
ix = [9, 3, 6, 5, 2];
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(vgrid, adif(:, ix));
axis([pv1, pv2, bmin, bmax])
legend(fname{ix}, 'location', 'eastoutside')
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

%----------------------------
% difference vs gauss filter
%----------------------------
figure(3); clf
subplot(3,1,1)
ix = [1,3,7,9];
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(vgrid, adif(:, ix) - gdif(:, ix));
axis([pv1, pv2, bmin, bmax])
title(sprintf('%s %s, FOR diff minus convolved FOR diff', proc, band))
legend(fname{ix}, 'location', 'eastoutside')
ylabel('dBT, K')
grid on; zoom on

subplot(3,1,2)
ix = [2,4,6,8];
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(vgrid, adif(:, ix) - gdif(:, ix));
axis([pv1, pv2, bmin, bmax])
legend(fname{ix}, 'location', 'eastoutside')
ylabel('dBT, K')
grid on; zoom on

subplot(3,1,3)
ix = [5];
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(vgrid, adif(:, ix) - gdif(:, ix));
axis([pv1, pv2, bmin, bmax])
legend(fname{ix}, 'location', 'eastoutside')
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

