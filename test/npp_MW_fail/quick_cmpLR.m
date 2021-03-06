%
% quick comparison of ccast and NOAA SDR data
%

addpath ../source
addpath ../motmsc/time
addpath ../motmsc/utils

ps = '/asl/cris/sdr60_npp/2019/107';
pg = '/asl/cris/geo60_npp/2019/107';
% fs = 'SCRIS_npp_d20190417_t0401119_e0409097_b38700_c20190417080910191357_noac_ops.h5';
% fg = 'GCRSO_npp_d20190417_t0401119_e0409097_b38700_c20190417080910185568_noac_ops.h5';
  fs = 'SCRIS_npp_d20190417_t0505039_e0513017_b38701_c20190417091304708731_noac_ops.h5';
  fg = 'GCRSO_npp_d20190417_t0505039_e0513017_b38701_c20190417091304703284_noac_ops.h5';
f1 = fullfile(ps, fs);
g1 = fullfile(pg, fg);
d1 = read_SCRIS(f1);
gx = read_GCRSO(g1);

p2 = '/asl/cris/ccast/sdr45_npp_LR/2019/107';
% g2 = 'CrIS_SDR_npp_s45_d20190417_t0400080_g041_v20a.mat';
  g2 = 'CrIS_SDR_npp_s45_d20190417_t0500080_g051_v20a.mat';
f2 = fullfile(p2, g2);
d2 = load(f2);

t1 = double(gx.FORTime);
t2 = d2.geo.FORTime;

display([datestr(iet2dnum(t1(1))), '  ', datestr(iet2dnum(t1(end)))])
display([datestr(iet2dnum(t2(1))), '  ', datestr(iet2dnum(t2(end)))])

[j1, j2] = seq_match(t1(:), t2(:));
fprintf(1, 'found %d matches\n', length(j1))

r1 = mod(j1-1, 30) + 1;
r2 = mod(j2-1, 30) + 1;
c1 = floor((j1-1)/30) + 1;
c2 = floor((j2-1)/30) + 1;

jLW = 5;
jSW = 1:9;
vLW = d2.vLW;
vSW = d2.vSW;
for i = 1 : length(c1)
  ts1 = datestr(iet2dnum(gx.FORTime(r1(i), c1(i))));
  ts2 = datestr(iet2dnum(d2.geo.FORTime(r2(i), c2(i))));
  lat = gx.Latitude(jLW, r1(i), c1(i));
  lon = gx.Longitude(jLW, r1(i), c1(i));
  fmt1 = 'FOR %d, %s, lat %3.1f lon %3.1f\n';
  fprintf(1, fmt1, r1(i), ts1, lat, lon);

  figure(1)
  y1 = d1.ES_RealLW(:, jLW, r1(i), c1(i));
  y2 = d2.rLW(:, jLW, r2(i), c2(i));
  b1 = rad2bt(vLW, y1);
  b2 = rad2bt(vLW, y2);
  subplot(2,1,1)
  plot(vLW, b1, vLW, b2)
  axis([650, 1100, 200, 300])
  title(sprintf('LW FOV %d', jLW))
  legend('noaa', 'ccast')
  grid on; zoom on
  subplot(2,1,2)
  plot(vLW, b1 - b2)
  axis([650, 1100, -1, 1])
  title(sprintf('LW FOV %d noaa minus ccast', jLW))
  grid on; zoom on

  figure(2)
  y1 = d1.ES_ImaginaryLW(:, jLW, r1(i), c1(i));
  y2 = d2.cLW(:, jLW, r2(i), c2(i));
% b1 = rad2bt(vLW, y1);
% b2 = rad2bt(vLW, y2);
  subplot(2,1,1)
  plot(vLW, y1, vLW, y2)
  axis([650, 1100, -1, 1])
  title(sprintf('LW complex resid FOV %d', jLW))
  legend('noaa', 'ccast')
  grid on; zoom on
  subplot(2,1,2)
  plot(vLW, y1 - y2)
  axis([650, 1100, -1, 1])
  title(sprintf('LW complex resid FOV %d noaa minus ccast', jLW))
  grid on; zoom on

% figure(2)
% y1 = d1.ES_RealSW(:, jSW, r1(i), c1(i));
% y2 = d2.rSW(:, jSW, r2(i), c2(i));
% b1 = rad2bt(vSW, y1);
% b2 = rad2bt(vSW, y2);
% subplot(2,1,1)
% plot(vSW, b2, vSW, b1)
% axis([1200, 1750, 200, 300])
% title(sprintf('SW FOV %d', jSW))
% legend('ccast', 'NOAA')
% grid on
% subplot(2,1,2)
% plot(vSW, b2 - b1)
% axis([1200, 1750, -1, 1])
% title(sprintf('SW FOV %d ccast minus NOAA', jSW))
% grid on

  pause
end

