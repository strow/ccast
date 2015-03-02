%
% ILS test 2 - newILS and oaffov as functions of arc steps
%

addpath ../source
addpath ../motmsc/utils

band = 'MW';
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
ichan = floor(0.6*npts);
fchan  = freq(ichan);
% fchan = user.v1 + .8 * (user.v2 - user.v1);

% newILS options
opt2 = struct;
opt2.wrap = 'sinc';

% arc count list 
alist = 1001:10:3000;

k = length(alist);
ils1 = zeros(npts, k);
ils2 = zeros(npts, k);

for j = 1 : k
  narc = alist(j);
  opt2.narc = narc;
  ils1(:, j) = newILS(ifov, inst, fchan, freq, opt2);
  [t1, srf2] = oaffov2(freq, fchan, opd, theta, hfov, narc);
  ils2(:, j) = srf2(:);
end

figure(1); clf
subplot(2,1,1)
ic = ichan + 2
plot(alist, ils1(ic, :), alist, ils2(ic, :))
legend('new ILS', 'oaffov', 'location', 'northeast')
title(sprintf('%s FOV %d ILS channel %d', band, ifov, ichan))
xlabel('integration arcs')
ylabel(sprintf('ILS at index %d', ic))
grid on; zoom on

subplot(2,1,2)
ic = ic + 1;
plot(alist, ils1(ic, :), alist, ils2(ic, :))
legend('new ILS', 'oaffov',  'location', 'southeast')
% title(sprintf('%s FOV %d ILS channel %d', band, ifov, ichan))
xlabel('integration arcs')
ylabel(sprintf('ILS at index %d', ic))
grid on; zoom on

figure(2); clf
ic = ichan + 4;
plot(alist, ils1(ic, :) - ils1(ic, end))
title(sprintf('%s FOV %d new ILS channel %d', band, ifov, ichan))
xlabel('integration arcs')
ylabel(sprintf('ILS change at index %d', ic))
grid on; zoom on

