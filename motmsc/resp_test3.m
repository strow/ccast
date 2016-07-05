%
% resp_test3 - compare kc2resp with kc2resp3
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

% channel test sepcs
dvL = 0.625;
dvM = 0.1;

% get CrIS user struct
opt1 = struct;
opt1.resmode = 'hires2';
wlaser = 773.13;
[instLW, userLW] = inst_params('LW', wlaser, opt1);
[instMW, userMW] = inst_params('MW', wlaser, opt1);
[instSW, userSW] = inst_params('SW', wlaser, opt1);

% high res resp
[rad1LW, frq1LW] = kc2resp(userLW, rkc, vkc);
[rad1MW, frq1MW] = kc2resp(userMW, rkc, vkc);
[rad1SW, frq1SW] = kc2resp(userSW, rkc, vkc);
rad1 = [rad1LW; rad1MW; rad1SW];
frq1 = [frq1LW; frq1MW; frq1SW];

% low res resp
[rad2LW, frq2LW] = kc2resp3(userLW, rkc, vkc, dvL, dvM);
[rad2MW, frq2MW] = kc2resp3(userMW, rkc, vkc, dvL, dvM);
[rad2SW, frq2SW] = kc2resp3(userSW, rkc, vkc, dvL, dvM);
rad2 = [rad2LW; rad2MW; rad2SW];
frq2 = [frq2LW; frq2MW; frq2SW];

bt1 = rad2bt(frq1, rad1);
bt2 = rad2bt(frq2, rad2);

figure(1); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
plot(frq1, bt1, frq1, bt2)
title(sprintf('kc2resp and LR2resp, fitting profile %d ', ip))
legend('kc2resp', 'LR2resp', 'location', 'best')
ylabel('BT')
grid on; zoom on

pfile = sprintf('resp_both_%03d', dvL * 1000);
saveas(gcf, pfile, 'png');
% export_fig([pfile,'.pdf'], '-m2', '-transparent')

figure(2); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
plot(frq1, bt2 - bt1)
ax = axis; tx = min(abs(ax(3:4))); axis([600, 2600, -tx, tx])
title(sprintf('LR2resp minus kc2resp, dvL = %5.3f', dvL));
xlabel('wavenumber')
ylabel('dBT')
grid on; zoom on

pfile = sprintf('resp_diff_%03d', dvL * 1000);
saveas(gcf, pfile, 'png')
% export_fig([pfile,'.pdf'], '-m2', '-transparent')

