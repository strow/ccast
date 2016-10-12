%
% cmp_sdr - compare two ccast SDR files
%

addpath ../source
addpath utils

% SDR files
sfile = 'SDR_d20160120_t0056495.mat';
sdir1 = '/asl/data/cris/ccast/h3a2newX/2016/020';
sdir2 = '/asl/data/cris/ccast/sdr60_hr/2016/020';

% plot labels
sname1 = 'h3a2newX';
sname2 = 'sdr60 hr';

band = 'LW';

sfile1 = fullfile(sdir1, sfile);
sfile2 = fullfile(sdir2, sfile);
d1 = load(sfile1);
d2 = load(sfile2);

switch upper(band)
  case 'LW', r1 = d1.rLW; v1 = d1.vLW; r2 = d2.rLW; v2 = d2.vLW;
  case 'MW', r1 = d1.rMW; v1 = d1.vMW; r2 = d2.rMW; v2 = d2.vMW;
  case 'SW', r1 = d1.rSW; v1 = d1.vSW; r2 = d2.rSW; v2 = d2.vSW;
end

% rid for plot name
rid = sfile(5:22); rtmp = rid; rtmp(10) = ' ';

% get user grid
wlaser = 773.1301;
[inst, user] = inst_params(band, wlaser);
vg = user.v1 : user.dv : user.v2;

% indices into user grid
n1 = length(v1);
n2 = length(v2);
i1 = interp1(v1, 1:n1, vg, 'nearest');
i2 = interp1(v2, 1:n2, vg, 'nearest');

%---------------------------------------
% compare a selected FOV, FOR, and scan
%---------------------------------------
ifov = 1;
ifor = 15;
iscan = 32;

x1 = real(rad2bt(vg, r1(i1, ifov, ifor, iscan)));
x2 = real(rad2bt(vg, r2(i2, ifov, ifor, iscan)));

figure(1); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(2,1,1)
plot(vg, x1, vg, x2)
title(sprintf('%s FOV %d FOR %d Scan %d', rtmp, ifov, ifor, iscan))
ylabel('BT, K')
legend(sname1, sname2, 'location', 'southeast')
grid on; zoom on

subplot(2,1,2)
plot(vg, x1 - x2)
xlabel('wavenumber')
ylabel('dBT, K')
legend([sname1, ' - ', sname2], 'location', 'southeast')
grid on; zoom on

%----------------------------------------------
% compare all FOVs for a selected FOR and scan
%----------------------------------------------

w1 = real(rad2bt(vg, r1(i1, :, ifor, iscan)));
w2 = real(rad2bt(vg, r2(i2, :, ifor, iscan)));

figure(2); clf
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(vg, w1 - w2)
legend(fovnames, 'location', 'southeast')
title(sprintf('%s FOR %d Scan %d', rtmp, ifor, iscan))
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

