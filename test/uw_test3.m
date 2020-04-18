%
% 3-way comparison of ccast, noaa, and uw, stats on matching obs
%

addpath ../source
addpath ../motmsc/time
addpath ../motmsc/utils
addpath /asl/packages/airs_decon/source

% choose a FOV and FOR
% jFOV = 5;
jFOV = input('FOV > ');
jFOR = 1:30;

nFOV = length(jFOV);
nFOR = length(jFOR);

% ccast granule
% p1 = './ccast_a4_eng_a2_new_ict/sdr45_npp_HR/2019/063';
% g1 = 'CrIS_SDR_npp_s45_d20190304_t1006080_g102_v20a.mat';
  p1 = '/asl/cris/ccast_a4_uw_a2_new_ict/sdr45_npp_HR/2019/062';
  g1 = 'CrIS_SDR_npp_s45_d20190303_t2106080_g212_v20a.mat';
f1 = fullfile(p1, g1);
d1 = load(f1);

% noaa granule
% p2 = '/home/motteler/cris/move_data/npp_scrif/2019/063';
% g2 = 'GCRSO-SCRIF_npp_d20190304_t1007039_e1015017_b38080_c20190507191953137970_nobc_ops.h5';
  p2 = '/home/motteler/cris/move_data/npp_scrif/2019/062';
  g2 = 'GCRSO-SCRIF_npp_d20190303_t2103039_e2111017_b38072_c20190507191924162690_nobc_ops.h5';
f2 = fullfile(p2, g2);
d2 = read_SCRIF(f2);
d2g = read_GCRSO(f2);

% uw granule
% p3 = '/home/motteler/shome/daac_test/SNPPCrISL1B.2/2019/063';
% g3 = 'SNDR.SNPP.CRIS.20190304T1006.m06.g102.L1B.std.v02_05.G.190304194948.nc';
  p3 = '/home/motteler/shome/daac_test/SNPPCrISL1B.2/2019/062';
  g3 = 'SNDR.SNPP.CRIS.20190303T2106.m06.g212.L1B.std.v02_05.G.190304043806.nc';
f3 = fullfile(p3, g3);
d3 = read_netcdf_lls(f3);

t1 = d1.geo.FORTime;
t2 = double(d2g.FORTime);
t3 = tai2iet(airs2tai(d3.obs_time_tai93));

fprintf(1, 'granule start times:\n')
display(['ccast ', datestr(iet2dnum(t1(1)))])
display(['noaa  ', datestr(iet2dnum(t2(1)))])
display(['wisc  ', datestr(iet2dnum(t3(1)))])

% match ccast and noaa scans for FOR 1
[i1, i2] = seq_match(t1(1,:), t2(1,:), 100);

% match ccast and uw scans for FOR 1
[j1, j3] = seq_match(t1(1,:), t3(1,:), 100);

% match noaa and uw scans for FOR 1
[k2, k3] = seq_match(t2(1,:), t3(1,:), 100);

% take the intersection of the matches
i1 = intersect(i1, j1);
i2 = intersect(i2, k2);
i3 = intersect(j3, k3);

% matchup info
k = length(i1);
fprintf(1, '%d scans match, %d obs match\n', k, k*nFOR)
j = floor(length(i1)/2);
mt = datestr(iet2dnum(t1(15, i1(j))));
mlat = d1.geo.Latitude(5, 15, i1(j));
mlon = d1.geo.Longitude(5, 15, i1(j));
fprintf(1, 'midpt %s, lat %3.1f lon %3.1f\n', mt, mlat, mlon)

%---------
% LW test
%---------

v1 = d1.vLW;
v3 = d3.wnum_lw;

r1 = double(squeeze(d1.rLW(:, jFOV, jFOR, i1)));
r2 = double(squeeze(d2.ES_RealLW(:, jFOV, jFOR, i2)));
r3 = double(squeeze(d3.rad_lw(:, jFOV, jFOR, i3)));

% r1 = hamm_app(r1(:,:)); r2 = hamm_app(r2(:,:)); r3 = hamm_app(r3(:,:));

b1 = real(rad2bt(v1, r1));
b2 = real(rad2bt(v1, r2));
b3 = real(rad2bt(v1, r3));

b1m = mean(b1(:,:),2);  % ccast
b2m = mean(b2(:,:),2);  % noaa
b3m = mean(b3(:,:),2);  % uw

figure(1)
subplot(3,1,1)
plot(v1, b2m - b1m)
axis([650, 1100, -0.2, 0.2])
title(sprintf('NOAA minus UMBC LW FOV %d', jFOV))
ylabel('dBT')
grid on

subplot(3,1,2)
plot(v1, b3m - b1m)
axis([650, 1100, -0.2, 0.2])
title('UW minus UMBC')
ylabel('dBT')
grid on

subplot(3,1,3)
plot(v1, b3m - b2m)
axis([650, 1100, -0.2, 0.2])
title('UW minus NOAA')
xlabel('wavenumber (cm-1)')
ylabel('dBT')
grid on

% saveas(gcf, sprintf('LW_FOV%d_hamm_SDR_diffs', jFOV), 'png')

%---------
% MW test
%---------

v1 = d1.vMW;
v3 = d3.wnum_mw;

r1 = double(squeeze(d1.rMW(:, jFOV, jFOR, i1)));
r2 = double(squeeze(d2.ES_RealMW(:, jFOV, jFOR, i2)));
r3 = double(squeeze(d3.rad_mw(:, jFOV, jFOR, i3)));

% r1 = hamm_app(r1(:,:)); r2 = hamm_app(r2(:,:)); r3 = hamm_app(r3(:,:));

b1 = real(rad2bt(v1, r1));
b2 = real(rad2bt(v1, r2));
b3 = real(rad2bt(v1, r3));

b1m = mean(b1(:,:),2);  % ccast
b2m = mean(b2(:,:),2);  % noaa
b3m = mean(b3(:,:),2);  % uw

figure(2)
subplot(3,1,1)
plot(v1, b2m - b1m)
axis([1200, 1750, -0.2, 0.2])
title(sprintf('NOAA minus UMBC MW FOV %d', jFOV))
ylabel('dBT')
grid on

subplot(3,1,2)
plot(v1, b3m - b1m)
axis([1200, 1750, -0.2, 0.2])
title('UW minus UMBC')
ylabel('dBT')
grid on

subplot(3,1,3)
plot(v1, b3m - b2m)
axis([1200, 1750, -0.2, 0.2])
title('UW minus NOAA')
xlabel('wavenumber (cm-1)')
ylabel('dBT')
grid on

% saveas(gcf, sprintf('MW_FOV%d_hamm_SDR_diffs', jFOV), 'png')

%---------
% SW test
%---------

v1 = d1.vSW;
v3 = d3.wnum_sw;

r1 = double(squeeze(d1.rSW(:, jFOV, jFOR, i1)));
r2 = double(squeeze(d2.ES_RealSW(:, jFOV, jFOR, i2)));
r3 = double(squeeze(d3.rad_sw(:, jFOV, jFOR, i3)));

% r1 = hamm_app(r1(:,:)); r2 = hamm_app(r2(:,:)); r3 = hamm_app(r3(:,:));

b1 = real(rad2bt(v1, r1(:,:)));
b2 = real(rad2bt(v1, r2(:,:)));
b3 = real(rad2bt(v1, r3(:,:)));

b1m = mean(b1(:,:),2);  % ccast
b2m = mean(b2(:,:),2);  % noaa
b3m = mean(b3(:,:),2);  % uw

figure(3)
subplot(3,1,1)
plot(v1, b2m - b1m)
axis([2150, 2550, -0.4, 0.4])
title(sprintf('NOAA minus UMBC SW FOV %d', jFOV))
ylabel('dBT')
grid on

subplot(3,1,2)
plot(v1, b3m - b1m)
axis([2150, 2550, -0.4, 0.4])
title('UW minus UMBC')
ylabel('dBT')
grid on

subplot(3,1,3)
plot(v1, b3m - b2m)
axis([2150, 2550, -0.4, 0.4])
title('UW minus NOAA')
xlabel('wavenumber (cm-1)')
ylabel('dBT')
grid on

% saveas(gcf, sprintf('SW_FOV%d_hamm_SDR_diffs', jFOV), 'png')

