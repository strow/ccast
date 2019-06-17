%
%  3-way comparison of ccast ref, ccast a4 and noaa a4 sdr data
%

addpath ../source
addpath ../motmsc/time
addpath ../motmsc/utils

jFOV = 1;  % select a FOV
jdir = 1;  % select sweep direction (0 or 1)

  dstr = '3 Mar 2019'; fstr = 'MW_good';
  p1 = '/home/motteler/cris/move_data/npp_scrif/2019/062';
  g1 = 'GCRSO-SCRIF_npp_d20190303_t0407119_e0415097_b38062_c20190507191704252101_nobc_ops.h5';
  p2 = './ccast_eng_a2_new_ict/sdr45_npp_HR/2019/062';
% p2 = '/asl/cris/ccast/sdr45_npp_HR/2019/062';
  p3 = './noaa_a4_eng_a2_new_ict/sdr45_npp_HR/2019/062';
  g2 = 'CrIS_SDR_npp_s45_d20190303_t0406080_g042_v20a.mat';
 
% dstr = '21 Apr 2019'; fstr = 'MW_fail';
% p1 = '/home/motteler/cris/move_data/npp_scrif/2019/111';
% g1 = 'GCRSO-SCRIF_npp_d20190421_t0400319_e0408297_b38757_c20190506160924977285_noac_ops.h5';
% p2 = '/asl/cris/ccast/sdr45_npp_HR/2019/111';
% p3 =       './test_a4/sdr45_npp_HR/2019/111';
% g2 = 'CrIS_SDR_npp_s45_d20190421_t0400080_g041_v20a.mat';

f1 = fullfile(p1, g1);
d1 = read_SCRIF(f1);
gx = read_GCRSO(f1);

f2 = fullfile(p2, g2);
f3 = fullfile(p3, g2);
d2 = load(f2);
d3 = load(f3);

t1 = double(gx.FORTime);
t2 = d2.geo.FORTime;
t3 = d3.geo.FORTime;

display([datestr(iet2dnum(t1(1))), '  ', datestr(iet2dnum(t1(end)))])
display([datestr(iet2dnum(t2(1))), '  ', datestr(iet2dnum(t2(end)))])

[j1, j2] = seq_match(t1(:), t2(:));
fprintf(1, 'found %d matches\n', length(j1))

r1 = mod(j1-1, 30) + 1;
r2 = mod(j2-1, 30) + 1;
c1 = floor((j1-1)/30) + 1;
c2 = floor((j2-1)/30) + 1;

% isequal(double(gx.FORTime(r1, c1)), d2.geo.FORTime(r2, c2))

vLW = d2.vLW;
vMW = d2.vMW;
vSW = d2.vSW;

% granule info
i = floor(length(r1)/2);
ts1 = datestr(iet2dnum(gx.FORTime(r1(i), c1(i))));
ts2 = datestr(iet2dnum(d2.geo.FORTime(r2(i), c2(i))));
lat = gx.Latitude(5, r1(i), c1(i));
lon = gx.Longitude(5, r1(i), c1(i));
fmt1 = 'match midpt FOR %d, %s, lat %3.1f lon %3.1f\n';
fprintf(1, fmt1, r1(i), ts1, lat, lon);

bt1 = []; bt2 = []; bt3 = [];
cr1 = []; cr2 = []; cr3 = [];

for i = 1 : length(c1)

  if mod(r1(i),2) ~= jdir, continue, end

  y1 = d1.ES_RealSW(:, jFOV, r1(i), c1(i));
  y2 = d2.rSW(:, jFOV, r2(i), c2(i));
  y3 = d3.rSW(:, jFOV, r2(i), c2(i));
  bt1 = [bt1, real(rad2bt(vSW, y1))];
  bt2 = [bt2, real(rad2bt(vSW, y2))];
  bt3 = [bt3, real(rad2bt(vSW, y3))];

  cr1 = [cr1, d1.ES_ImaginarySW(:, jFOV, r1(i), c1(i))];
  cr2 = [cr2, d2.cSW(:, jFOV, r2(i), c2(i))];
  cr3 = [cr3, d3.cSW(:, jFOV, r2(i), c2(i))];

  if r1(i) ~= r2(i), error('FOR mismatch'), end

end

btm1 = mean(bt1, 2);
btm2 = mean(bt2, 2);
btm3 = mean(bt3, 2);
crm1 = mean(cr1, 2);
crm2 = mean(cr2, 2);
crm3 = mean(cr3, 2);
crs1 = std(cr1, 0, 2);
crs2 = std(cr2, 0, 2);
crs3 = std(cr3, 0, 2);

figure(1)
subplot(3,1,1)
plot(vSW, btm1, vSW, btm2, vSW, btm3)
axis([2150, 2560, 200, 300])
title(sprintf('%s SW BT mean, FOV %d sweep %d', dstr, jFOV, jdir))
legend('noaa a4', 'ccast ref', 'ccast a4', 'location', 'southeast')
ylabel('BT (K)')
grid on; zoom on

subplot(3,1,2)
plot(vSW, btm1 - btm2)
axis([2150, 2560, -0.3, 0.3])
title('noaa minus ccast ref')
ylabel('dBT (K)')
grid on; zoom on

subplot(3,1,3)
plot(vSW, btm1 - btm3)
axis([2150, 2560, -0.3, 0.3])
title('noaa minus ccast a4')
xlabel('wavenumber (cm-1)')
ylabel('dBT (K)')
grid on; zoom on

s1 = sprintf('SW_%s_BT_fov%d_sd%d', fstr, jFOV, jdir);
% saveas(gcf, s1, 'fig')

figure(2)
subplot(2,1,1)
plot(vSW, crm1, vSW, crm2, vSW, crm3)
axis([2150, 2560, -1.5e-2, 1.5e-2])
title(sprintf('%s SW imag resid mean, FOV %d sweep %d', dstr, jFOV, jdir))
legend('noaa a4', 'ccast ref', 'ccast a4', 'location', 'north')
ylabel('mw sr-1 m-2')
grid on; zoom on

subplot(2,1,2)
plot(vSW, crs1, vSW, crs2, vSW, crs3)
axis([2150, 2560, 4e-3, 1.2e-2])
title(sprintf('SW imag resid std, FOV %d sweep %d', jFOV, jdir))
legend('noaa a4', 'ccast ref', 'ccast a4', 'location', 'north')
ylabel('mw sr-1 m-2')
xlabel('wavenumber (cm-1)')
grid on; zoom on

s2 = sprintf('SW_%s_imag_fov%d_sd%d', fstr, jFOV, jdir);
% saveas(gcf, s2, 'fig')

