%
% ILS test 1 - compare newILS, oaffov, and UW ILS
%

addpath ../source
addpath ../motmsc/utils

band = 'SW';
wlaser = 773.13;
opts = struct;
opts.resmode = 'hires2';

[inst, user] = inst_params(band, wlaser, opts);
dv   = inst.dv;
freq = inst.freq;
ichan = floor(0.6*inst.npts);
ichan = 3;
fchan = freq(ichan); 

% new UMBC ILS
narc = 2001;
opts = struct;
opts.narc = narc;
opts.wrap = 'sinc';
srf1 = newILS(1, inst, fchan, freq, opts);
srf2 = newILS(2, inst, fchan, freq, opts);
srf5 = newILS(5, inst, fchan, freq, opts);

% interpolate to a finer frequency grid
[srf1, frq1] = finterp2(srf1(:), freq, 10);
[srf2, frq2] = finterp2(srf2(:), freq, 10);
[srf5, frq5] = finterp2(srf5(:), freq, 10);

figure(1); clf
plot(frq1, srf1, frq2, srf2, frq5, srf5)
% axis([floor(fchan-6), ceil(fchan+6), -0.3, 1.1])
k = 6;
v1 = floor(max(fchan-k, freq(1)));
v2 = floor(min(fchan+k, freq(end)));
axis([v1, v2, -0.3, 1.1])
title(sprintf('CrIS SW ILS comparison, channel %d', ichan))
legend('fov 1', 'fov 2', 'fov 5')
zoom on; grid on

saveas(gcf, sprintf('ILS_SW_chan_%d', ichan), 'fig')

