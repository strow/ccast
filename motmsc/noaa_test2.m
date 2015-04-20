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
  test = 'iasi';
% test = 'kcarta';
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

figure(1); clf
subplot(2,1,1)
plot(f, calc_mean)
% axis([pv1, pv2, 200, 300])
title('iasi sarta calculated spectra')
ylabel('BT')
grid on; zoom on

subplot(2,1,2)
plot(f, noaa4_diff, 'r', f, ccast_diff, 'g')
axis([pv1, pv2, -2, 2])
title('ccast and noaa4 obs minus calc')
legend('noaa4', 'ccast', 'location', 'north')
xlabel('wavenumber')
ylabel('dBT')
grid on; zoom on
% export_fig('iasi_sarta_1.pdf', '-m2', '-transparent')

figure(2); clf
subplot(2,1,1)
plot(f, noaa4_diff, 'r', f, ccast_diff, 'g')
axis([650, 750, -1.5, 2.5])
title('obs minus calc LW detail')
legend('noaa4', 'ccast', 'location', 'northeast')
ylabel('dBT')
grid on; zoom on

subplot(2,1,2)
plot(f, noaa4_diff, 'r', f, ccast_diff, 'g')
axis([1000, 1100, -1, 1])
title('obs minus calc LW detail')
legend('noaa4', 'ccast', 'location', 'northeast')
xlabel('wavenumber')
ylabel('dBT')
grid on; zoom on
% export_fig('iasi_sarta_2.pdf', '-m2', '-transparent')

figure(3); clf
subplot(2,1,1)
plot(f, noaa4_diff, 'r', f, ccast_diff, 'g')
axis([1500, 1800, -1, 1])
title('obs minus calc MW detail')
legend('noaa4', 'ccast', 'location', 'northeast')
ylabel('dBT')
grid on; zoom on

subplot(2,1,2)
plot(f, noaa4_diff, 'r', f, ccast_diff, 'g')
axis([2200, 2300, -2, 2])
title('obs minus calc SW detail')
legend('noaa4', 'ccast', 'location', 'northwest')
xlabel('wavenumber')
ylabel('dBT')
grid on; zoom on
% export_fig('iasi_sarta_3.pdf', '-m2', '-transparent')

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
% export_fig('FOV_FOR_bins.pdf', '-m2', '-transparent')

