%
% compare NOAA and CCAST SDRs with radiances calculated from clear
% matchups for the 17-19 Feb 2015 NOAA test
%

addpath utils
addpath /home/motteler/matlab/export_fig

%-----------------------
% choose input data set
%-----------------------
% test = input('iasi or kcarta ? ', 's');
% test = 'iasi';
  test = 'kcarta';
switch test
  case 'iasi'
    fprintf(1, 'iasi sarta -> iasi2cris\n')
    load gran_clear.mat
    calc_bt  = btcal;
    ccast_bt = btccast;
    noaa4_bt = bt4;
    ifov     = p4.ifov;
    xtrack   = p4.xtrack;
    pv1 = 600; pv2 = 2600;
  case 'kcarta'
    fprintf(1, 'using kcarta -> kc2cris\n')
    load kcarta_and_obs
    calc_bt  = real(rad2bt(f, rk));
    ccast_bt = real(rad2bt(f, rc));
    noaa4_bt = real(rad2bt(f, r4));
    pv1 = 600; pv2 = 1800;
  otherwise
    error('unknown test type')
end

%------------------------
% overall obs minus calc
%------------------------
calc_mean = mean(calc_bt, 2);
ccast_mean = mean(ccast_bt, 2);
noaa4_mean = mean(noaa4_bt, 2);

ccast_diff = ccast_mean - calc_mean;
noaa4_diff = noaa4_mean - calc_mean;

ccast_filt = gauss_filt(ccast_diff);
noaa4_filt = gauss_filt(noaa4_diff);

ccast_ddif = ccast_diff - ccast_filt;
noaa4_ddif = noaa4_diff - noaa4_filt;

figure(1); clf
subplot(2,1,1)
plot(f, noaa4_diff, 'r', f, ccast_diff, 'g')
axis([pv1, pv2, -2, 2])
title('ccast and noaa4 obs minus calc')
legend('noaa4', 'ccast')
ylabel('dBT')
grid on; zoom on

subplot(2,1,2)
plot(f, noaa4_ddif, 'r', f, ccast_ddif, 'g');
axis([pv1, pv2, -2, 2])
title('ccast and noaa4 double difference')
legend('noaa4', 'ccast')
xlabel('wavenumber')
ylabel('dBT')
grid on; zoom on
% export_fig('kcarta_all_1.pdf', '-m2', '-transparent')

%-----------------------------
% even - odd sweep difference
%-----------------------------

% sweep direction 0
i0 = find(rem(ifov, 2) == 0);
calc_mean  = mean(calc_bt(:, i0), 2);
ccast_mean = mean(ccast_bt(:, i0), 2);
noaa4_mean = mean(noaa4_bt(:, i0), 2);

ccast_diff = ccast_mean - calc_mean;
noaa4_diff = noaa4_mean - calc_mean;

ccast_filt = gauss_filt(ccast_diff);
noaa4_filt = gauss_filt(noaa4_diff);

ccast_ddif0 = ccast_diff - ccast_filt;
noaa4_ddif0 = noaa4_diff - noaa4_filt;

% sweep direction 1
i1 = find(rem(ifov, 2) == 1);
calc_mean  = mean(calc_bt(:, i1), 2);
ccast_mean = mean(ccast_bt(:, i1), 2);
noaa4_mean = mean(noaa4_bt(:, i1), 2);

ccast_diff = ccast_mean - calc_mean;
noaa4_diff = noaa4_mean - calc_mean;

ccast_filt = gauss_filt(ccast_diff);
noaa4_filt = gauss_filt(noaa4_diff);

ccast_ddif1 = ccast_diff - ccast_filt;
noaa4_ddif1 = noaa4_diff - noaa4_filt;

% finally, compare sweep directions
ccast_sdiff = ccast_ddif0 - ccast_ddif1;
noaa4_sdiff = noaa4_ddif0 - noaa4_ddif1;

figure(2); clf
subplot(2,1,1)
plot(f, ccast_sdiff)
axis([pv1, pv2, -0.5, 0.5])
title('ccast even minus odd sweeps')
ylabel('dBT')
grid on; zoom on

subplot(2,1,2)
plot(f, noaa4_sdiff)
axis([pv1, pv2, -0.5, 0.5])
title('noaa4 even minus odd sweeps')
xlabel('wavenumber')
ylabel('dBT')
grid on; zoom on
% export_fig('kcarta_all_2.pdf', '-m2', '-transparent')

%-----------------------------
% selected FOV obs minus calc
%-----------------------------

jFOV = input('select a FOV > ');
% jFOV = 1;
ix = find(ifov == jFOV);

calc_mean = mean(calc_bt(:, ix), 2);
ccast_mean = mean(ccast_bt(:, ix), 2);
noaa4_mean = mean(noaa4_bt(:, ix), 2);

ccast_diff = ccast_mean - calc_mean;
noaa4_diff = noaa4_mean - calc_mean;
ccast_noaa = ccast_mean - noaa4_mean;

figure(3); clf
subplot(2,1,1)
plot(f, noaa4_diff, 'r', f, ccast_diff, 'g')
axis([pv1, pv2, -2, 2])
title(sprintf('ccast and noaa4 FOV %d obs minus calc', jFOV))
legend('noaa4', 'ccast')
ylabel('dBT')
grid on; zoom on

subplot(2,1,2)
plot(f, ccast_noaa)
axis([pv1, pv2, -2, 2])
title(sprintf('ccast minus noaa4 FOV %d', jFOV))
xlabel('wavenumber')
ylabel('dBT')
grid on; zoom on
% export_fig(sprintf('kcarta_FOV%d.pdf', jFOV), '-m2', '-transparent')

return

%---------------------
% basic stats on data
%---------------------
figure(4); clf
subplot(2,1,1)
hist(double(xtrack), 1:30)
ax = axis; ax(1) = 0; ax(2) = 30; axis(ax);
title('FOR and FOV samples')
xlabel('FOR')
ylabel('samples')

subplot(2,1,2)
hist(double(ifov), 1:9)
ax = axis; ax(1) = 0; ax(2) = 10; axis(ax);
xlabel('FOV')
ylabel('samples')

% export_fig('figure4.pdf', '-m2', '-transparent')

