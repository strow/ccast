%
% ILS test 4 - benchmark new ILS, oaffov, and UW ILS
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

srf1 = zeros(npts, npts);
srf2 = zeros(npts, npts);
srf3 = zeros(npts, npts);

profile clear
profile on

% new UMBC ILS
opt2 = struct;
opt2.narc = 2001;
opt2.wrap = 'sinc';
for i = 1 : npts
  fchan = freq(i);
  srf1(:, i) = newILS(ifov, inst, fchan, freq, opt2);
end

% old UMBC ILS
nslice = 2001;
for i = 1 : npts
  fchan = freq(i);
  [t1, t2] = oaffov2(freq, fchan, opd, theta, hfov, nslice);
  srf2(:, i) = t2(:);
end

% Dave's UW ILS
for i = 1 : npts
  fchan = freq(i);
  srf3(:, i) = computeIls(freq, fchan, opd, theta, hfov);
end

profile viewer

