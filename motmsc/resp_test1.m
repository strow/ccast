%
% resp_test1 - compare kc2resp with kc2cris
%

addpath /home/motteler/matlab/export_fig
addpath /home/motteler/cris/ccast/source
addpath /home/motteler/cris/airs_decon/source
addpath /home/motteler/cris/ccast/motmsc/utils

% kcarta test data
kcdir = '/home/motteler/cris/sergio/JUNK2012/';
flist =  dir(fullfile(kcdir, 'convolved_kcart*.mat'));

% choose a kcarta file
ip = 1;
d1 = load(fullfile(kcdir, flist(ip).name));
vkc = d1.w(:); rkc = d1.r(:);

% get CrIS user struct
band = 'LW';
opt1 = struct;
opt1.user_res = 'hires';
opt1.inst_res = 'hires3';
wlaser = 773.13;
[inst, user] = inst_params(band, wlaser, opt1);

% specify guard channels
ngc = 0;

% basic convolution
opt2 = struct;
opt2.ngc = ngc;
[rad1, frq1] = kc2cris(user, rkc, vkc, opt2);

% convolution with responsivity
[rad2, frq2] = kc2resp(user, rkc, vkc, ngc);

bt1 = rad2bt(frq1, rad1);
bt2 = rad2bt(frq2, rad2);

figure(1); clf
subplot(2,1,1)
plot(frq1, bt1, frq1, bt2)
title(sprintf('%s fitting profile %d kc2resp and kc2cris', band, ip))
legend('kc2cris', 'kc2resp', 'location', 'best')
ylabel('BT')
grid on; zoom on

subplot(2,1,2)
plot(frq1, bt2 - bt1)
ax = axis; ax(3) = -0.5; ax(4) = 0.5; axis(ax)
title('kc2resp minus kc2cris')
xlabel('wavenumber')
ylabel('dBT')
grid on; zoom on

% pfile = sprintf('resp_filt_%s.pdf', band);
% export_fig(pfile, '-m2', '-transparent')

