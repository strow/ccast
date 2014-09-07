% 
% interp_test1 -- test finterp as used in CrIS processing
% 
% compare kcarta convolved to kc2cris at the cris user grid with
% kcarta convolved to kc2cris at the sensor grid and interpolated
% to the user grid with finterp.
%

% use my bcast utils and HDF libs
addpath /home/motteler/cris/ccast/source
addpath /home/motteler/cris/airs_decon/test
addpath /home/motteler/cris/ccast/motmsc/utils

% kcarta test data
kcdir = '/home/motteler/cris/sergio/JUNK2012/';
flist =  dir(fullfile(kcdir, 'convolved_kcart*.mat'));

% choose a kcarta file
i = 10;
d1 = load(fullfile(kcdir, flist(i).name));
vkc = d1.w(:); rkc = d1.r(:);

% get CrIS inst and user params
band = 'SW';
opts = struct;
opts.resmode = 'hires2';
wlaser = 773.1301;  % nominal value
[inst, user] = inst_params(band, wlaser, opts);

% set wlaser so inst grid == user grid
wlaser = 1e7/(inst.df/(2*user.opd/inst.npts));
[inst, user] = inst_params(band, wlaser, opts);

% convolve kcarta to cris at the user grid
[rad1, frq1] = kc2cris(inst, user, rkc, vkc);

% convolve kcarta to cris at an arbitrary wlaser 
w2 = 773.1301;
[inst2, user2] = inst_params(band, w2, opts);
[rad2, frq2] = kc2cris(inst2, user2, rkc, vkc);

% interpolate back to the user grid
opt2 = struct;
opt2.tol = 1e-8;
[rad3, frq3] = finterp(rad2, frq2, inst.dv, opt2);
frq3 = frq3(:);

[j1, j3] = seq_match(frq1, frq3);
rad1 = rad1(j1); frq1 = frq1(j1);
rad3 = rad3(j3); frq3 = frq3(j3);

bt1 = real(rad2bt(frq1, rad1));
bt3 = real(rad2bt(frq3, rad3));

figure(1); clf
plot(frq1, bt1, frq3, bt3)
legend('true', 'interp')
xlabel('wavenumber')
ylabel('BT, K')
grid on; zoom on

figure(2); clf
plot(frq1, bt3 - bt1);
axis([user.v1, user.v2, -0.14, 0.14])
title(sprintf('profile %d interp minus true %s %g', i, band, opt2.tol))
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on
% saveas(gcf, sprintf('prof_%d_%s_%g', i, band, opt2.tol), 'png')

