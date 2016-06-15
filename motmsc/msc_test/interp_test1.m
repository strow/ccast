% 
% interp_test1 -- test finterp as used in CrIS processing
% 
% compare kcarta convolved directly to the CrIS user grid with
% kcarta convolved to the sensor grid and interpolated to the user
% grid with finterp.  note airs_decon/test/interp_test4 is similar
% but does the tests with all the fitting profiles
%

addpath /home/motteler/cris/ccast/source
addpath /home/motteler/cris/airs_decon/test
addpath /home/motteler/cris/ccast/motmsc/utils

% kcarta test data
kcdir = '/home/motteler/cris/sergio/JUNK2012/';
flist =  dir(fullfile(kcdir, 'convolved_kcart*.mat'));

% choose a kcarta file
i = 1;
d1 = load(fullfile(kcdir, flist(i).name));
vkc = d1.w(:); rkc = d1.r(:);

% get CrIS inst and user params
band = 'SW';
opt1 = struct;
opt1.resmode = 'hires2';

% 1. convolve kcarta to cris at the sensor grid
wlaser = 773.13;  % test value
[inst1, user1] = inst_params(band, wlaser, opt1);
[rad1, frq1] = kc2inst(inst1, user1, rkc, vkc);

% 2. convolve kcarta to cris at the user grid
wlaser = 1e7/(inst1.df/(2*user1.opd/inst1.npts));
[inst2, user2] = inst_params(band, wlaser, opt1);
% [rad2, frq2] = kc2inst(inst2, user2, rkc, vkc);
[rad2, frq2] = kc2cris(inst2, user2, rkc, vkc);

% 3. use finterp to interpolate sensor to user grids
opt2 = struct; opt2.tol = 1e-6; opt2.info = 1;
[rad3, frq3] = finterp(rad1, frq1, user2.dv, opt2);

% 4. use finterp to interpolate back to the sensor grid
[rad4, frq4] = finterp(rad3, frq3, inst1.dv, opt2);

% compare 2 & 3: interpolated sensor to user
[j2, j3] = seq_match(frq2, frq3);
rad2 = rad2(j2); frq2 = frq2(j2);
rad3 = rad3(j3); frq3 = frq3(j3);
bt2 = real(rad2bt(frq2, rad2));
bt3 = real(rad2bt(frq3, rad3));

figure(1); clf
plot(frq2, bt3 - bt2);
axis([user2.v1, user2.v2, -0.2, 0.2])
title(sprintf('profile %d finterp minus user %s', i, band))
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

% compare 1 & 4: finterp forward and back 
[j1, j4] = seq_match(frq1, frq4);
rad1 = rad1(j1); frq1 = frq1(j1);
rad4 = rad4(j4); frq4 = frq4(j4);
bt1 = real(rad2bt(frq1, rad1));
bt4 = real(rad2bt(frq4, rad4));

figure(2); clf
plot(frq1, bt4 - bt1);
axis([user2.v1, user2.v2, -1, 1])
title(sprintf('profile %d finterp forward and back %s', i, band))
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on
