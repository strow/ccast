
addpath /home/motteler/cris/bcast/source
addpath /home/motteler/cris/bcast/motmsc/utils

band = 'LW';
wlaser = 773.1301;
[inst, user] = inst_params(band, wlaser);

ifov = 1;
fchan = 949.71;

fgrid = inst.freq;
opd = inst.opd;
thetac = inst.foax(ifov);
hfov = inst.frad(ifov);
nslice = 2001;

[frq1, srf1] = oaffov2(fgrid, fchan, opd, thetac, hfov, nslice);

N = 864;

[frq2, srf2] = oaffov_p(fgrid, fchan, opd, thetac, hfov, nslice, N);

figure(1); clf
plot(frq1, srf1, frq2, srf2)
legend('sinc ILS', 'psinc ILS')
title('sinc and periodic sinc ILS')
xlabel('wavenumber')
ylabel('normalized weight')
grid on; zoom on

figure(2); clf
plot(frq1, srf2 - srf1)
title('periodic minus regular sinc ILS')
xlabel('wavenumber')
ylabel('difference')
grid on; zoom on

