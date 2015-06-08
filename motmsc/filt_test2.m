%
% filt_test2 -- compare ccast and new noaa processing filters
%

addpath ../source
addpath /home/motteler/matlab/export_fig

opts = struct;
opts.resmode = 'lowres';
opts.resmode = 'hires2';
ftype1 = 'noaa1';
ftype2 = 'noaa2';

% all in one plot
figure(1); clf

%------------
% LW filters
%------------
[inst, user] = inst_params('LW', 773.13, opts);
freq = inst.freq; npts = inst.npts;
f1 = f_atbd(1, 1 : npts, ftype1);
f2 = f_atbd(1, 1 : npts, ftype2);
f3 = bandpass(freq, ones(npts,1), user.v1, user.v2, user.vr);

subplot(3,2,1)
plot(freq, f3, freq, f1, freq, f2, user.v1, 1, '+k')
axis([user.v1-30, user.v1+15, -0.1, 1.1])
legend('ccast', 'NOAA old', 'NOAA new', 'user grid', 'location', 'southeast')
title('LW left')
grid on; zoom on;

subplot(3,2,2)
plot(freq, f3, freq, f1, freq, f2, user.v2, 1, '+k')
axis([user.v2-15, user.v2+30, -0.1, 1.1])
legend('ccast', 'NOAA old', 'NOAA new', 'user grid', 'location', 'southwest')
title('LW right')
grid on; zoom on;

%------------
% MW filters
%------------
[inst, user] = inst_params('MW', 773.13, opts);
freq = inst.freq; npts = inst.npts;
f1 = f_atbd(2, 1 : npts, ftype1);
f2 = f_atbd(2, 1 : npts, ftype2);
f3 = bandpass(freq, ones(npts,1), user.v1, user.v2, user.vr);

subplot(3,2,3)
plot(freq, f3, freq, f1, freq, f2, user.v1, 1, '+k')
axis([user.v1-40, user.v1+15, -0.1, 1.1])
legend('ccast', 'NOAA old', 'NOAA new', 'user grid', 'location', 'southeast')
title('MW left')
grid on; zoom on;

subplot(3,2,4)
plot(freq, f3, freq, f1, freq, f2, user.v2, 1, '+k')
axis([user.v2-15, user.v2+45, -0.1, 1.1])
legend('ccast', 'NOAA old', 'NOAA new', 'user grid', 'location', 'southwest')
title('MW right')
grid on; zoom on;

%------------
% SW filters
%------------
[inst, user] = inst_params('SW', 773.13, opts);
freq = inst.freq; npts = inst.npts;
f1 = f_atbd(3, 1 : npts, ftype1);
f2 = f_atbd(3, 1 : npts, ftype2);
f3 = bandpass(freq, ones(npts,1), user.v1, user.v2, user.vr);

subplot(3,2,5)
plot(freq, f3, freq, f1, freq, f2, user.v1, 1, '+k')
axis([user.v1-40, user.v1+15, -0.1, 1.1])
legend('ccast', 'NOAA old', 'NOAA new', 'user grid', 'location', 'southeast')
title('SW left')
grid on; zoom on;

subplot(3,2,6)
plot(freq, f3, freq, f1, freq, f2, user.v2, 1, '+k')
axis([user.v2-15, user.v2+40, -0.1, 1.1])
legend('ccast', 'NOAA old', 'NOAA new', 'user grid', 'location', 'southwest')
title('SW right')
grid on; zoom on;

export_fig('cal_filts.pdf', '-m2', '-transparent')
% saveas(gcf, 'cal_filts', 'png')

