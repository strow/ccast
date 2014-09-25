%
% ILS test 1 - compare newILS, oaffov, and UW ILS
%

addpath ../source
addpath ../motmsc/utils

band = 'SW';
wlaser = 773.13;
opts = struct;
opts.resmode = 'hires2';
ifov = input('fov index > ');

[inst, user] = inst_params(band, wlaser, opts);
dv   = inst.dv;
npts = inst.npts;
opd  = inst.opd;
freq = inst.freq;
foax = inst.foax;
frad = inst.frad;

hfov = frad(ifov);
theta = foax(ifov);
  fchan  = freq(floor(0.6*npts));
% fchan = user.v1 + .8 * (user.v2 - user.v1);

% new UMBC ILS
narc = 2001;
opts = struct;
opts.narc = narc;
opts.wrap = 'sinc';
srf1 = newILS(ifov, inst, fchan, freq, opts);

% old UMBC ILS
nslice = 2001;
[t1, srf2] = oaffov2(freq, fchan, opd, theta, hfov, nslice);
% [t1, srf2] = oaffov_p(freq, fchan, opd, theta, hfov, nslice, npts);
srf2 = srf2(:);

% Dave's UW ILS
srf3 = computeIls(freq, fchan, opd, theta, hfov);
% srf3 = srf3 / sum(srf3);

% interpolate to a finer frequency grid
% [srf1, frq1] = finterp2(srf1(:), freq, 10);
% [srf2, frq2] = finterp2(srf2(:), freq, 10);
% [srf3, frq3] = finterp2(srf3(:), freq, 10);
% freq = frq1;

figure(1); clf
subplot(2,1,1)
plot(freq, srf1, freq, srf2)
title(sprintf('FOV %d comparison', ifov))
legend('new ILS', 'oaffov')
zoom on; grid on

subplot(2,1,2)
plot(freq, srf1 - srf2)
title('new ILS - oaffov')
zoom on; grid on

figure(2); clf
subplot(2,1,1)
plot(freq, srf1, freq, srf3)
title(sprintf('FOV %d comparison', ifov))
legend('new ILS', 'wisc')
zoom on; grid on

subplot(2,1,2)
plot(freq, srf1 - srf3)
title('new ILS - UW ILS')
zoom on; grid on

[rms(srf1(:) - srf2(:)), rms(srf1(:) - srf3(:))]

