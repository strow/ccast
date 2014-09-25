%
% psinc_demo - sinc and psinc integrated and single-ray ILS
%

addpath ../source
addpath ../motmsc/utils

% get sensor grid
band = 'SW';
opts = struct;
opts.resmode = 'lowres';
% opts.resmode = 'hires2';
wlaser = 773.1301;
[inst, user] = inst_params(band, wlaser, opts);

% demo parameters
ifov = 1;
% fchan = 949.71;
fchan = user.v1 + .2 * (user.v2 - user.v1);

% oaffov parameters
fgrid = inst.freq;
opd = inst.opd;
thetac = inst.foax(ifov);
hfov = inst.frad(ifov);
nslice = 2001;
N = inst.npts;

% regular sinc integrated ILS
[frq1, srf1] = oaffov2(fgrid, fchan, opd, thetac, hfov, nslice);

% periodic sinc integrated ILS
[frq2, srf2] = oaffov_p(fgrid, fchan, opd, thetac, hfov, nslice, N);

% regular sinc single-ray ILS
srf3 = rsinc(2*(fgrid - fchan*cos(thetac))*opd);
srf3 = srf3 / sum(srf3);

% periodic sinc single-ray ILS
srf4 = psinc(2*(fgrid - fchan*cos(thetac))*opd, N);
srf4 = srf4 / sum(srf4);

% periodic sinc extended
frq5 = 0 : inst.dv : 4000;
srf5 = psinc(2*(frq5 - fchan*cos(thetac))*opd, N);

% sinc and psinc ILS plots
figure(1); clf
subplot(2,1,1)
plot(frq1, srf1, frq2, srf2)
legend('sinc ILS', 'psinc ILS')
title(sprintf('FOV %d sinc and periodic sinc ILS', ifov))
xlabel('wavenumber')
ylabel('normalized weight')
grid on; zoom on

subplot(2,1,2)
plot(frq1, srf2 - srf1)
title('periodic minus regular sinc ILS')
xlabel('wavenumber')
ylabel('difference')
grid on; zoom on

% single-ray and ILS plots
figure(2); clf
plot(frq1, srf1, frq2, srf2, fgrid, srf3, fgrid, srf4)
title(sprintf('FOV %d single-ray and ILS comparison', ifov))
legend('sinc ILS', 'psinc ILS', 'sinc ray', 'psinc ray')
xlabel('wavenumber')
ylabel('normalized weight')
grid on; zoom on

% extended periodic sinc
figure(3); clf
plot(frq5, srf5)
title('periodic sinc with wraps')
xlabel('wavenumber')
ylabel('not normalized')
grid on; zoom on

% check subinterval sums
m = numel(srf5) - N;
t1 = zeros(m,1);
for i = 1 : m
  t1(i) = sum(srf5(i : i + N -1));
end

figure(4); clf
plot(t1)
title('N point sums')
xlabel('starting index')
ylabel('sum')
grid on; zoom on

