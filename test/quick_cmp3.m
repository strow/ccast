%
% quick comparison of ccast and ADL data
%

addpath ../source
addpath ../motmsc/time

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
jMW = 9;
jSW = 1:9
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

  pause
end

