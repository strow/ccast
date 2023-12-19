%
% quick comparison of ccast and ADL data
%

addpath ../source
addpath ../motmsc/time
addpath ../motmsc/utils

sp1 = '/asl/cris/sdr60_j01/2023/278';
gp1 = '/asl/cris/geo60_j01/2023/278';

% sf1 = 'SCRIF_j01_d20231005_t0100479_e0108457_b30456_c20231005014639203000_oeac_ops.h5';
% gf1 = 'GCRSO_j01_d20231005_t0100479_e0108457_b30456_c20231005014639592000_oeac_ops.h5';

% sf1 = 'SCRIF_j01_d20231005_t1812399_e1820377_b30466_c20231005185033057000_oeac_ops.h5';
% gf1 = 'GCRSO_j01_d20231005_t1812399_e1820377_b30466_c20231005185033484000_oeac_ops.h5';

sf1 = 'SCRIF_j01_d20231005_t1900399_e1908377_b30467_c20231005194137454000_oeac_ops.h5';
gf1 = 'GCRSO_j01_d20231005_t1900399_e1908377_b30467_c20231005194137882000_oeac_ops.h5';

sf1 = fullfile(sp1, sf1);
gf1 = fullfile(gp1, gf1);
d1 = read_SCRIF(sf1);
gx = read_GCRSO(gf1);

p2 = '/asl/cris/ccast/sdr45_j01_HR/2023/278/';

% f2 = 'CrIS_SDR_j01_s45_d20231005_t0100080_g011_v20d.mat';
% f2 = 'CrIS_SDR_j01_s45_d20231005_t1812080_g183_v20d.mat';
  f2 = 'CrIS_SDR_j01_s45_d20231005_t1900080_g191_v20d.mat';

f2 = fullfile(p2, f2);
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

jLW = 3;
jMW = 3;
jSW = 3;
vLW = d2.vLW;
vMW = d2.vMW;
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
  plot(vLW, b2, vLW, b1)
  axis([650, 1100, 200, 300])
  title(sprintf('LW FOV %d', jLW))
  legend('ccast', 'ADL')
  grid on
  subplot(2,1,2)
  plot(vLW, b2 - b1)
  axis([650, 1100, -1, 1])
  title(sprintf('LW FOV %d ccast minus ADL', jLW))
  grid on

  figure(2)
  y1 = d1.ES_RealMW(:, jMW, r1(i), c1(i));
  y2 = d2.rMW(:, jMW, r2(i), c2(i));
  b1 = rad2bt(vMW, y1);
  b2 = rad2bt(vMW, y2);
  subplot(2,1,1)
  plot(vMW, b2, vMW, b1)
  axis([1200, 1750, 200, 300])
  title(sprintf('MW FOV %d', jMW))
  legend('ccast', 'ADL')
  grid on
  subplot(2,1,2)
  plot(vMW, b2 - b1)
  axis([1200, 1750, -1, 1])
  title(sprintf('MW FOV %d ccast minus ADL', jMW))
  grid on

  figure(3)
  y1 = d1.ES_RealSW(:, jSW, r1(i), c1(i));
  y2 = d2.rSW(:, jSW, r2(i), c2(i));
  b1 = rad2bt(vSW, y1);
  b2 = rad2bt(vSW, y2);
  subplot(2,1,1)
  plot(vSW, b2, vSW, b1)
% axis([1200, 1750, 200, 300])
  title(sprintf('SW FOV %d', jSW))
  legend('ccast', 'ADL')
  grid on
  subplot(2,1,2)
  plot(vSW, b2 - b1)
% axis([1200, 1750, -1, 1])
  title(sprintf('SW FOV %d ccast minus ADL', jSW))
  grid on

  pause
end

