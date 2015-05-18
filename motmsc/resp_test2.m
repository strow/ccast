%
% resp_test2 -- try flattened responsivity.
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
band = 'MW';
opt1 = struct;
opt1.resmode = 'hires2';
wlaser = 773.13;
[inst, user] = inst_params(band, wlaser, opt1);

% load normalized responsivity
load resp_filt.mat

flat = 0.64;
filt1 = filt_mw;
freq = freq_mw;
k = length(filt1);
filt2 = min(filt1, ones(k,1) * flat);
for i = 1 : 5
  filt2 = gauss_filt(filt2);
end
filt3 = filt2 / flat;

filt_mw = filt3;
save resp_filt2 filt_lw filt_mw filt_sw ...
                freq_lw freq_mw freq_sw

filt4 = bandpass(freq, ones(k,1), user.v1, user.v2, user.vr);

figure(1); clf
plot(freq, filt1, freq, filt2, freq, filt3, freq, filt4)
title('MW responsivity with truncation')
legend('responsivity', 'truncated responsivity', ...
       'truncated normalized', 'ccast reference', 'location', 'south')
ylabel('weight')
xlabel('wavenumber')
grid on; zoom on
saveas(gcf, 'figure_1', 'fig')

% specify guard channels
ngc = 0;

% basic convolution
[rad1, frq1] = kc2cris(user, rkc, vkc, ngc);

% convolution with responsivity
[rad2, frq2] = kc2resp(user, rkc, vkc, ngc);

% convolution with truncated responsivity
[rad3, frq3] = kc2resp2(user, rkc, vkc, ngc);

bt1 = rad2bt(frq1, rad1);
bt2 = rad2bt(frq2, rad2);
bt3 = rad2bt(frq3, rad3);

figure(2); clf
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
saveas(gcf, 'figure_2', 'fig')

figure(3); clf
subplot(2,1,1)
plot(frq1, bt3 - bt1)
ax = axis; ax(3) = -0.5; ax(4) = 0.5; axis(ax)
title('kc2trunc minus kc2cris')
xlabel('wavenumber')
ylabel('dBT')
grid on; zoom on

subplot(2,1,2)
plot(frq1, bt3 - bt2)
ax = axis; ax(3) = -0.5; ax(4) = 0.5; axis(ax)
title('kc2trunc minus kc2resp')
xlabel('wavenumber')
ylabel('dBT')
grid on; zoom on
saveas(gcf, 'figure_3', 'fig')

