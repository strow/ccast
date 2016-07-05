%
% cal_plot2 - plots from cal_test2
%

% load tests
% cf = load('cal_h3a2new_flat');
% cr = load('cal_h3a2new_resp');
  cf = load('cal_sdr60_hr_flat');
  cr = load('cal_sdr60_hr_resp');
  nf = load('cal_h3noaa4_flat');
  nr = load('cal_h3noaa4_resp');

% plot setup
addpath utils
addpath /home/motteler/matlab/export_fig
fname = fovnames;
fcolor = fovcolors;
fn = 0; 

%---------------------
% obs - calc all FOVs
%---------------------
fn = fn + 1; figure(fn); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(3,1,1)
set(gcf, 'DefaultAxesColorOrder', fcolor);
plot(nr.vobs, nr.bobs - nr.bcal)
axis([600, 2600, -2, 2])
title('noaa obs minus resp calc, all FOVs')
ylabel('dBT')
grid on; zoom on

subplot(3,1,2)
set(gcf, 'DefaultAxesColorOrder', fcolor);
plot(cf.vobs, cf.bobs - cf.bcal)
axis([600, 2600, -2, 2])
title('ccast obs minus flat calc, all FOVs')
ylabel('dBT')
grid on; zoom on

subplot(3,1,3)
set(gcf, 'DefaultAxesColorOrder', fcolor);
plot(cf.vobs, cf.bobs - nr.bobs)
axis([600, 2600, -0.6, 0.6])
title('ccast obs minus noaa obs, all FOVs')
xlabel('wavenumber')
ylabel('dBT')
grid on; zoom on

% saveas(gcf, 'cal_summary', 'png')
% export_fig('cal_summary.pdf', '-m2', '-transparent')

%---------------------------
% LW zoom direct comparison
%---------------------------
fn = fn + 1; figure(fn); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
cc = 'k'; nc = 'r'; 
subplot(3,1,1)
iFOV = 1;
plot(cf.vobs, cf.bobs(:, iFOV) - cf.bcal(:, iFOV), cc, ...
     nr.vobs, nr.bobs(:, iFOV) - nr.bcal(:, iFOV), nc)
axis([650, 680, -1, 1])
legend('ccast flat', 'noaa resp')
title(sprintf('obs minus calc FOV %d', iFOV))
ylabel('dBT')
grid on; zoom on

subplot(3,1,2)
iFOV = 2;
plot(cf.vobs, cf.bobs(:, iFOV) - cf.bcal(:, iFOV), cc, ...
     nr.vobs, nr.bobs(:, iFOV) - nr.bcal(:, iFOV), nc);
axis([650, 680, -1, 1])
legend('ccast flat', 'noaa resp')
title(sprintf('obs minus calc FOV %d', iFOV))
ylabel('dBT')
grid on; zoom on

subplot(3,1,3)
iFOV = 5;
plot(cf.vobs, cf.bobs(:, iFOV) - cf.bcal(:, iFOV), cc, ...
     nr.vobs, nr.bobs(:, iFOV) - nr.bcal(:, iFOV), nc);
axis([650, 680, -1, 1])
legend('ccast flat', 'noaa resp')
title(sprintf('obs minus calc FOV %d', iFOV))
ylabel('dBT')
grid on; zoom on

% saveas(gcf, 'cal_LW_detail', 'png')
% export_fig('cal_LW_detail.pdf', '-m2', '-transparent')

%---------------------------
% MW zoom direct comparison
%---------------------------
fn = fn + 1; figure(fn); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
cc = 'k'; nc = 'r'; 
subplot(3,1,1)
iFOV = 1;
plot(cf.vobs, cf.bobs(:, iFOV) - cf.bcal(:, iFOV), cc, ...
     nr.vobs, nr.bobs(:, iFOV) - nr.bcal(:, iFOV), nc)
axis([1720, 1750, -0.5, 1.5])
legend('ccast flat', 'noaa resp')
title(sprintf('obs minus calc FOV %d', iFOV))
ylabel('dBT')
grid on; zoom on

subplot(3,1,2)
iFOV = 2;
plot(cf.vobs, cf.bobs(:, iFOV) - cf.bcal(:, iFOV), cc, ...
     nr.vobs, nr.bobs(:, iFOV) - nr.bcal(:, iFOV), nc);
axis([1720, 1750, -0.5, 1.5])
legend('ccast flat', 'noaa resp')
title(sprintf('obs minus calc FOV %d', iFOV))
ylabel('dBT')
grid on; zoom on

subplot(3,1,3)
iFOV = 5;
plot(cf.vobs, cf.bobs(:, iFOV) - cf.bcal(:, iFOV), cc, ...
     nr.vobs, nr.bobs(:, iFOV) - nr.bcal(:, iFOV), nc);
axis([1720, 1750, -0.5, 1.5])
legend('ccast flat', 'noaa resp')
title(sprintf('obs minus calc FOV %d', iFOV))
ylabel('dBT')
grid on; zoom on

% saveas(gcf, 'cal_MW_detail', 'png')
% export_fig('cal_MW_detail.pdf', '-m2', '-transparent')

%---------------------------
% SW zoom direct comparison
%---------------------------
fn = fn + 1; figure(fn); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
cc = 'k'; nc = 'r'; 
subplot(3,1,1)
iFOV = 1;
plot(cf.vobs, cf.bobs(:, iFOV) - cf.bcal(:, iFOV), cc, ...
     nr.vobs, nr.bobs(:, iFOV) - nr.bcal(:, iFOV), nc)
% axis([2330, 2390, -2, 2])
  axis([2230, 2290, -2, 2])
legend('ccast flat', 'noaa resp', 'location', 'northwest')
title(sprintf('obs minus calc FOV %d', iFOV))
ylabel('dBT')
grid on; zoom on

subplot(3,1,2)
iFOV = 2;
plot(cf.vobs, cf.bobs(:, iFOV) - cf.bcal(:, iFOV), cc, ...
     nr.vobs, nr.bobs(:, iFOV) - nr.bcal(:, iFOV), nc);
% axis([2330, 2390, -2, 2])
  axis([2230, 2290, -2, 2])
legend('ccast flat', 'noaa resp', 'location', 'northwest')
title(sprintf('obs minus calc FOV %d', iFOV))
ylabel('dBT')
grid on; zoom on

subplot(3,1,3)
iFOV = 5;
plot(cf.vobs, cf.bobs(:, iFOV) - cf.bcal(:, iFOV), cc, ...
     nr.vobs, nr.bobs(:, iFOV) - nr.bcal(:, iFOV), nc);
% axis([2330, 2390, -2, 2])
  axis([2230, 2290, -2, 2])
legend('ccast flat', 'noaa resp', 'location', 'northwest')
title(sprintf('obs minus calc FOV %d', iFOV))
ylabel('dBT')
grid on; zoom on

% saveas(gcf, 'cal_SW_detail', 'png')
% export_fig('cal_SW_detail.pdf', '-m2', '-transparent')

%-----------------------
% noaa breakouts by FOV 
%-----------------------
fn = fn + 1; figure(fn); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(3,1,1)
ix = [1,3,7,9];
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(nr.vobs, nr.bobs(:, ix) - nr.bcal(:, ix))
% axis([600, 2600, -3, 3])
  axis([650, 680, -1, 1])
% axis([1720, 1750, -0.5, 0.5])
% axis([1720, 1750, -1.0, 1.5])
legend(fname{ix}, 'location', 'eastoutside')
title('noaa obs minus resp calc corner FOVs')
ylabel('dBT')
grid on; zoom on

subplot(3,1,2)
ix = [2,4,6,8];
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(nr.vobs, nr.bobs(:, ix) - nr.bcal(:, ix))
% axis([600, 2600, -3, 3])
  axis([650, 680, -1, 1])
% axis([1720, 1750, -0.5, 0.5])
% axis([1720, 1750, -1.0, 1.5])
legend(fname{ix}, 'location', 'eastoutside')
title('noaa obs minus resp calc side FOVs')
ylabel('dBT')
grid on; zoom on

subplot(3,1,3)
ix = 5;
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(nr.vobs, nr.bobs(:, ix) - nr.bcal(:, ix))
% axis([600, 2600, -3, 3])
  axis([650, 680, -1, 1])
% axis([1720, 1750, -0.5, 0.5])
% axis([1720, 1750, -1.0, 1.5])
legend(fname{ix}, 'location', 'eastoutside')
title('noaa obs minus resp calc center FOV')
ylabel('dBT')
grid on; zoom on

% saveas(gcf, 'cal_noaa_LW', 'png')
% export_fig('cal_noaa_LW.pdf', '-m2', '-transparent')

%------------------------
% ccast breakouts by FOV
%------------------------
fn = fn + 1; figure(fn); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(3,1,1)
ix = [1,3,7,9];
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(cf.vobs, cf.bobs(:, ix) - cf.bcal(:, ix))
% axis([600, 2600, -3, 3])
  axis([650, 680, -1, 1])
% axis([1720, 1750, -0.5, 0.5])
% axis([1720, 1750, -1.0, 1.5])
legend(fname{ix}, 'location', 'eastoutside')
title('ccast obs minus flat calc corner FOVs')
ylabel('dBT')
grid on; zoom on

subplot(3,1,2)
ix = [2,4,6,8];
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(cf.vobs, cf.bobs(:, ix) - cf.bcal(:, ix))
% axis([600, 2600, -3, 3])
  axis([650, 680, -1, 1])
% axis([1720, 1750, -0.5, 0.5])
% axis([1720, 1750, -1.0, 1.5])
legend(fname{ix}, 'location', 'eastoutside')
title('ccast obs minus flat calc side FOVs')
ylabel('dBT')
grid on; zoom on

subplot(3,1,3)
ix = 5;
set(gcf, 'DefaultAxesColorOrder', fcolor(ix, :));
plot(cf.vobs, cf.bobs(:, ix) - cf.bcal(:, ix))
% axis([600, 2600, -3, 3])
  axis([650, 680, -1, 1])
% axis([1720, 1750, -0.5, 0.5])
% axis([1720, 1750, -1.0, 1.5])
legend(fname{ix}, 'location', 'eastoutside')
title('ccast obs minus flat calc center FOV')
ylabel('dBT')
grid on; zoom on

% saveas(gcf, 'cal_ccast_LW', 'png')
% export_fig('cal_ccast_LW.pdf', '-m2', '-transparent')

%------------------------------
% double diff all FOVs default 
%------------------------------
fn = fn + 1; figure(fn); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(2,1,1)
set(gcf, 'DefaultAxesColorOrder', fcolor);
plot(nr.vobs, (nr.bobs - nr.bcal) - (nr.aobs - nr.acal))
axis([600, 2600, -2, 2])
title('noaa resp double diff, all FOVs')
ylabel('dBT')
grid on; zoom on

subplot(2,1,2)
set(gcf, 'DefaultAxesColorOrder', fcolor);
plot(cf.vobs, (cf.bobs - cf.bcal) - (cf.aobs - cf.acal))
axis([600, 2600, -2, 2])
title('ccast flat double diff, all FOVs')
ylabel('dBT')
grid on; zoom on

% saveas(gcf, 'cal_ddif_1', 'fig')
% export_fig('cal_ddif_1.pdf', '-m2', '-transparent')

%--------------------------------
% double diff all FOVs alternate
%--------------------------------
fn = fn + 1; figure(fn); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(2,1,1)
set(gcf, 'DefaultAxesColorOrder', fcolor);
plot(nr.vobs, (nf.bobs - nf.bcal) - (nf.aobs - nf.acal))
axis([600, 2600, -2, 2])
title('noaa flat double diff, all FOVs')
ylabel('dBT')
grid on; zoom on

subplot(2,1,2)
set(gcf, 'DefaultAxesColorOrder', fcolor);
plot(cf.vobs, (cr.bobs - cr.bcal) - (cr.aobs - cr.acal))
axis([600, 2600, -2, 2])
title('ccast resp double diff, all FOVs')
ylabel('dBT')
grid on; zoom on

% saveas(gcf, 'cal_ddif_2', 'png')
% export_fig('cal_ddif_2.pdf', '-m2', '-transparent')

%------------------------------
% double diff all FOVs LW zoom
%------------------------------
fn = fn + 1; figure(fn); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(2,1,1)
set(gcf, 'DefaultAxesColorOrder', fcolor);
plot(nr.vobs, (nr.bobs - nr.bcal) - (nr.aobs - nr.acal))
% axis([600, 2600, -2, 2])
  axis([650, 680, -0.6, 0.6])
% axis([650, 1100, -0.6, 0.6])
title('noaa resp double diff, all FOVs')
ylabel('dBT')
grid on; zoom on

subplot(2,1,2)
set(gcf, 'DefaultAxesColorOrder', fcolor);
plot(cf.vobs, (cf.bobs - cf.bcal) - (cf.aobs - cf.acal))
% axis([600, 2600, -2, 2])
  axis([650, 680, -0.6, 0.6])
% axis([650, 1100, -0.6, 0.6])
title('ccast flat double diff, all FOVs')
ylabel('dBT')
grid on; zoom on

% saveas(gcf, 'ddif_LW_zoom', 'fig')
% export_fig('ddif_LW_zoom.pdf', '-m2', '-transparent')

%------------------------------
% double diff all FOVs MW zoom
%------------------------------
fn = fn + 1; figure(fn); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(2,1,1)
set(gcf, 'DefaultAxesColorOrder', fcolor);
plot(nr.vobs, (nr.bobs - nr.bcal) - (nr.aobs - nr.acal))
% axis([600, 2600, -2, 2])
  axis([1720, 1750, -0.6, 0.6])
% axis([1200, 1760, -0.8, 0.8])
title('noaa resp double diff, all FOVs')
ylabel('dBT')
grid on; zoom on

subplot(2,1,2)
set(gcf, 'DefaultAxesColorOrder', fcolor);
plot(cf.vobs, (cf.bobs - cf.bcal) - (cf.aobs - cf.acal))
% axis([600, 2600, -2, 2])
  axis([1720, 1750, -0.6, 0.6])
% axis([1200, 1760, -0.8, 0.8])
title('ccast flat double diff, all FOVs')
ylabel('dBT')
grid on; zoom on

% saveas(gcf, 'ddif_MW_zoom', 'fig')
% export_fig('ddif_MW_zoom.pdf', '-m2', '-transparent')

