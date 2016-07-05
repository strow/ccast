%
% filt_test3 -- compare noaa high and extended res filters
%

addpath ../source

%-----------
% LW filter 
%-----------

opts = struct;
opts.inst_res = 'hires2';
[inst2, user] = inst_params('LW', 773.13, opts);
x2 = inst2.freq;
n2 = inst2.npts;
i2 = 1 : n2;
f2 = f_atbd(1, i2, 'noaa2');

opts.inst_res = 'hires3';
[inst3, user] = inst_params('LW', 773.13, opts);
x3 = inst3.freq;
n3 = inst3.npts;
i3 = 1 : n3;
f3 = f_atbd(1, i3, 'noaa3');

figure(1); clf
subplot(1,2,1)
plot(x2, f2, x3, f3)
axis([620, 645, -0.1, 1.1])
title('LW left')
legend('hires2', 'hires3', 'location', 'northwest')
grid on; zoom on;

subplot(1,2,2)
plot(x2, f2, x3, f3)
axis([1100, 1125, -0.1, 1.1])
title('LW right')
legend('hires2', 'hires3', 'location', 'northeast')
grid on; zoom on;

%-----------
% SW filter 
%-----------

opts = struct;
opts.inst_res = 'hires2';
[inst2, user] = inst_params('SW', 773.13, opts);
x2 = inst2.freq;
n2 = inst2.npts;
i2 = 1 : n2;
f2 = f_atbd(3, i2, 'noaa2');

opts.inst_res = 'hires3';
[inst3, user] = inst_params('SW', 773.13, opts);
x3 = inst3.freq;
n3 = inst3.npts;
i3 = 1 : n3;
f3 = f_atbd(3, i3, 'noaa3');

figure(2); clf
subplot(1,2,1)
plot(x2, f2, x3, f3)
axis([2120, 2140, -0.1, 1.1])
title('SW left')
legend('hires2', 'hires3', 'location', 'northwest')
grid on; zoom on;

subplot(1,2,2)
plot(x2, f2, x3, f3)
axis([2560, 2590, -0.1, 1.1])
title('SW right')
legend('hires2', 'hires3', 'location', 'northeast')
grid on; zoom on;

