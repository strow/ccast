%
% nedn_plot -- show NEdN and NEdT from mean_nedn data
%

addpath utils

  d1 = load('nedn_nedn_hr3.mat');
% d1 = load('nedn_e5_Pn_ag.mat');
% d2 = load('ccast_e5_Pn_ag_15-16.mat');

nednLW = gauss_filt(mean(d1.nmLW, 3));
nednMW = gauss_filt(mean(d1.nmMW, 3));
nednSW = gauss_filt(mean(d1.nmSW, 3));

vLW = d1.vLW; vMW = d1.vMW; vSW = d1.vSW;

% rLW = real(bt2rad(vLW, d2.bmLW)) + nednLW;
% rMW = real(bt2rad(vMW, d2.bmMW)) + nednMW;
% rSW = real(bt2rad(vSW, d2.bmSW)) + nednSW;

% nedtLW = real(rad2bt(vLW, rLW)) - d2.bmLW;
% nedtMW = real(rad2bt(vMW, rMW)) - d2.bmMW;
% nedtSW = real(rad2bt(vSW, rSW)) - d2.bmSW;

t_ict = 280.2;
rLW = real(bt2rad(vLW, t_ict)) * ones(1, 9) + nednLW;
rMW = real(bt2rad(vMW, t_ict)) * ones(1, 9) + nednMW;
rSW = real(bt2rad(vSW, t_ict)) * ones(1, 9) + nednSW;

nedtLW = real(rad2bt(vLW, rLW)) - t_ict;
nedtMW = real(rad2bt(vMW, rMW)) - t_ict;
nedtSW = real(rad2bt(vSW, rSW)) - t_ict;

% plot names and colors
fname = fovnames;
fcolor = fovcolors;

figure(1); clf
set(gcf, 'Units','centimeters', 'Position', [2, 2, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fcolor);

subplot(3,1,1)
plot(vLW, nednLW);
axis([640, 1100, 0, 1])
legend(fname, 'location', 'eastoutside')
title('ccast LW NEdN')
ylabel('NEdN')
grid on; zoom on

subplot(3,1,2)
plot(vMW, nednMW);
axis([1200, 1760, 0, 0.2])
title('ccast MW NEdN')
ylabel('NEdN')
grid on; zoom on

subplot(3,1,3)
plot(vSW, nednSW);
axis([2150, 2560, 0.002, 0.012])
title('ccast SW NEdN')
xlabel('wavenumber')
ylabel('NEdN')
grid on; zoom on
% saveas(gcf, 'ccast_NEdN', 'png')

figure(2); clf
set(gcf, 'Units','centimeters', 'Position', [3, 3, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fcolor);

subplot(3,1,1)
plot(vLW, nedtLW);
axis([640, 1100, 0, 1])
legend(fname, 'location', 'eastoutside')
title('ccast LW NEdT at 280K')
ylabel('NEdT')
grid on; zoom on

subplot(3,1,2)
plot(vMW, nedtMW);
axis([1200, 1760, 0, 1])
title('ccast MW NEdT at 280K')
ylabel('NEdT')
grid on; zoom on

subplot(3,1,3)
plot(vSW, nedtSW);
axis([2150, 2560, 0, 1])
title('ccast SW NEdN at 280K')
xlabel('wavenumber')
ylabel('NEdT')
grid on; zoom on
% saveas(gcf, 'ccast_NEdT', 'png')



