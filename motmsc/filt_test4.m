%
% filt_test4 -- compare compare old and new bandpass filters
%

addpath ../source
addpath /home/motteler/matlab/export_fig

opts = struct;
opts.resmode = 'hires2';

% all in one plot
figure(1); clf

%------------
% LW filters
%------------
[inst, user] = inst_params('LW', 773.13, opts);
freq = inst.freq; npts = inst.npts;
f1 = bandpass1(freq, ones(npts,1), user.v1, user.v2, user.vr);
f2 = bandpass2(freq, ones(npts,1), user.v1, user.v2, user.vr);

subplot(3,2,1)
plot(freq, f1, 'or', freq, f2, 'og', user.v1, 1, '+k')
axis([user.v1-20, user.v1+5, -0.1, 1.1])
legend('old filt', 'new filt', 'user grid', 'location', 'southeast')
title('LW left')
grid on; zoom on;

subplot(3,2,2)
plot(freq, f1, 'or', freq, f2, 'og',user.v2, 1, '+k')
axis([user.v2-5, user.v2+20, -0.1, 1.1])
legend('old filt', 'new filt', 'user grid', 'location', 'southwest')
title('LW right')
grid on; zoom on;

%------------
% MW filters
%------------
[inst, user] = inst_params('MW', 773.13, opts);
freq = inst.freq; npts = inst.npts;
f1 = bandpass1(freq, ones(npts,1), user.v1, user.v2, user.vr);
f2 = bandpass2(freq, ones(npts,1), user.v1, user.v2, user.vr);

subplot(3,2,3)
plot(freq, f1, 'or', freq, f2, 'og', user.v1, 1, '+k')
axis([user.v1-25, user.v1+5, -0.1, 1.1])
legend('old filt', 'new filt', 'user grid', 'location', 'southeast')
title('MW left')
grid on; zoom on;

subplot(3,2,4)
plot(freq, f1, 'or', freq, f2,'og',  user.v2, 1, '+k')
axis([user.v2-5, user.v2+25, -0.1, 1.1])
legend('old filt', 'new filt', 'user grid', 'location', 'southwest')
title('MW right')
grid on; zoom on;

%------------
% SW filters
%------------
[inst, user] = inst_params('SW', 773.13, opts);
freq = inst.freq; npts = inst.npts;
f1 = bandpass1(freq, ones(npts,1), user.v1, user.v2, user.vr);
f2 = bandpass2(freq, ones(npts,1), user.v1, user.v2, user.vr);

subplot(3,2,5)
plot(freq, f1, 'or', freq, f2, 'og', user.v1, 1, '+k')
axis([user.v1-25, user.v1+5, -0.1, 1.1])
legend('old filt', 'new filt', 'user grid', 'location', 'southeast')
title('SW left')
grid on; zoom on;

subplot(3,2,6)
plot(freq, f1, 'or', freq, f2, 'og', user.v2, 1, '+k')
axis([user.v2-5, user.v2+25, -0.1, 1.1])
legend('old filt', 'new filt', 'user grid', 'location', 'southwest')
title('SW right')
grid on; zoom on;

export_fig('cal_filts.pdf', '-m2', '-transparent')
% saveas(gcf, 'cal_filts', 'png')

