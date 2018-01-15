%
% quick comparison of ccast vs ADL frequency
%

addpath ../source
addpath ../motmsc/time
addpath /home/motteler/cris/cris_test/focal_fit

p1 = '/asl/s1/strow/ADL';
g1 = 'GCRSO_j01_d20180108_t1527129_e1527427_b00728_c20180112032711274647_ADu_ops.h5';
f1 = 'SCRIF_j01_d20180108_t1527129_e1527427_b00728_c20180112032711196399_ADu_ops.h5';
f1 = fullfile(p1, f1);
g1 = fullfile(p1, g1);
d1 = read_SCRIF(f1);
gx = read_GCRSO(g1);

p2 = '/asl/data/cris/ccast/sdr45_j01_HR/2018/008';
g2 = 'CrIS_SDR_j01_s45_d20180108_t1524010_g155_v20a.mat';
f2 = fullfile(p2, g2);
d2 = load(f2);

vLW = d2.vLW; vMW = d2.vMW; vSW = d2.vSW;

t1 = double(gx.FORTime);
t2 = d2.geo.FORTime;

display([datestr(iet2dnum(t1(1))), '  ', datestr(iet2dnum(t1(end)))])
display([datestr(iet2dnum(t2(1))), '  ', datestr(iet2dnum(t2(end)))])

[j1, j2] = seq_match(t1(:), t2(:));
fprintf(1, 'found %d matches\n', length(j1))

% LW dv
r1 = d1.ES_RealLW(:, :, j1);
r2 = d2.rLW(:, :, j2);
r1 = mean(r1, 3);
r2 = mean(r2, 3);
b1 = real(rad2bt(vLW, r1));
b2 = real(rad2bt(vLW, r2));
ppmlist = -4e-6 : 0.1e-6 : 10e-6;
[dmin, imin] = find_dv(vLW, b2, b1, 740, 840, ppmlist);
display('LW dv')
rprint(ppmlist(imin) * -1e6)

% MW dv
r1 = d1.ES_RealMW(:, :, j1);
r2 = d2.rMW(:, :, j2);
r1 = mean(r1, 3);
r2 = mean(r2, 3);
b1 = real(rad2bt(vMW, r1));
b2 = real(rad2bt(vMW, r2));
ppmlist = -4e-6 : 0.1e-6 : 10e-6;
[dmin, imin] = find_dv(vMW, b2, b1, 1200, 1600, ppmlist);
display('MW dv')
rprint(ppmlist(imin) * -1e6)

% SW dv
r1 = d1.ES_RealSW(:, :, j1);
r2 = d2.rSW(:, :, j2);
r1 = mean(r1, 3);
r2 = mean(r2, 3);
b1 = real(rad2bt(vSW, r1));
b2 = real(rad2bt(vSW, r2));
ppmlist = -4e-6 : 0.1e-6 : 10e-6;
[dmin, imin] = find_dv(vSW, b2, b1, 2320, 2370, ppmlist);
display('SW dv')
rprint(ppmlist(imin) * -1e6)

return

subplot(2,1,1)
plot(vSW, b2, vSW, b1)
axis([2150, 2550, 200, 300])
title('SW mean spectra')
grid on
subplot(2,1,2)
plot(vSW, b2 - b1)
axis([2150, 2550, -2, 2])
title('ccast minus adl')
grid on


