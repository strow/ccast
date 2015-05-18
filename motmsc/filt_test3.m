%
% filt_test3 -- show ATBD regular res filters by index 
%

addpath ../source

opts = struct;
opts.resmode = 'lowres';

% all in one plot
figure(1); clf

%-----------
% LW filter 
%-----------
[inst, user] = inst_params('LW', 773.13, opts);
ix = 1 : inst.npts;
ff = f_atbd(1, ix);

subplot(3,2,1)
plot(ix, ff)
axis([40, 80, -0.1, 1.1])
title('LW left')
grid on; zoom on;

subplot(3,2,2)
plot(ix, ff)
axis([785, 825, -0.1, 1.1])
title('LW right')
grid on; zoom on;

%-----------
% MW filter 
%-----------
[inst, user] = inst_params('MW', 773.13, opts);
n = inst.npts;
k = 50;

subplot(3,2,3)
ix = 1 : k;
plot(ix, f_atbd(2, ix))
axis([10, 40, -0.1, 1.1])
title('MW left')
grid on; zoom on;

subplot(3,2,4)
ix = n-k+1 : n;
plot(ix, f_atbd(2, ix))
axis([490, 520, -0.1, 1.1])
title('MW right')
grid on; zoom on;

%-----------
% SW filter 
%-----------
[inst, user] = inst_params('SW', 773.13, opts);
n = inst.npts;
k = 25;

subplot(3,2,5)
ix = 1 : k;
plot(ix, f_atbd(3, ix))
axis([5, 20, -0.1, 1.1])
title('SW left')
grid on; zoom on;

subplot(3,2,6)
ix = n-k+1 : n;
plot(ix, f_atbd(3, ix))
axis([180, 195, -0.1, 1.1])
title('SW right')
grid on; zoom on;

