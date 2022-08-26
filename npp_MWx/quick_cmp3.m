%
% quick comparison of ccast and noaa data matchup obs
%

addpath ../source
addpath ../motmsc/time

% get noaa sdr data
p1 = '/asl/cris/sdr60_npp/2021/194';
g1 = 'SCRIF_npp_d20210713_t0802399_e0810377_b50308_c20210713121036742788_oebc_ops.h5';
d1 = read_SCRIF(fullfile(p1, g1));

% get noaa geo data
p2 = '/asl/cris/geo60_npp/2021/194';
g2 = 'GCRSO_npp_d20210713_t0802399_e0810377_b50308_c20210713121036748800_oebc_ops.h5';
d2 = read_GCRSO(fullfile(p2, g2))

% get corresponding ccast data
p3 = '/asl/cris/ccast/sdr45_npp_HR/2021/194';
g3 = 'CrIS_SDR_npp_s45_d20210713_t0806080_g082_v20d.mat';
d3 = load(fullfile(p3, g3));

t1 = double(d2.FORTime);  % NOAA time
t2 = d3.geo.FORTime;      % ccast time

display([datestr(iet2dnum(t1(1))), '  ', datestr(iet2dnum(t1(end)))])
display([datestr(iet2dnum(t2(1))), '  ', datestr(iet2dnum(t2(end)))])

[j1, j2] = seq_match(t1(:), t2(:));
fprintf(1, 'found %d matches\n', length(j1))

r1 = mod(j1-1, 30) + 1;
r2 = mod(j2-1, 30) + 1;
c1 = floor((j1-1)/30) + 1;
c2 = floor((j2-1)/30) + 1;

jLW = 5;
jSW = 5;
% jSW = 1:9
vLW = d3.vLW;
vSW = d3.vSW;
vSW = d3.vSW;
for i = 1 : length(c1)
  ts1 = datestr(iet2dnum(d2.FORTime(r1(i), c1(i))));
  ts2 = datestr(iet2dnum(d3.geo.FORTime(r2(i), c2(i))));
  lat = d2.Latitude(jLW, r1(i), c1(i));
  lon = d2.Longitude(jLW, r1(i), c1(i));
  fmt1 = 'FOR %d, %s, lat %3.1f lon %3.1f\n';
  fprintf(1, fmt1, r1(i), ts1, lat, lon);

  figure(1)
  y1 = d1.ES_RealLW(:, jLW, r1(i), c1(i));
  y2 = d3.rLW(:, jLW, r2(i), c2(i));
  b1 = rad2bt(vLW, y1);
  b2 = rad2bt(vLW, y2);
  subplot(2,1,1)
  plot(vLW, b2, vLW, b1)
  xlim([650, 1100])
  title(sprintf('LW FOV %d', jLW))
  legend('ccast', 'ADL')
  grid on
  subplot(2,1,2)
  plot(vLW, b2 - b1)
  xlim([650, 1100])
  ylim([-1, 1])
  title(sprintf('LW FOV %d ccast minus ADL', jLW))
  grid on

  figure(2)
  y1 = d1.ES_RealSW(:, jSW, r1(i), c1(i));
  y2 = d3.rSW(:, jSW, r2(i), c2(i));
  b1 = rad2bt(vSW, y1);
  b2 = rad2bt(vSW, y2);
  subplot(2,1,1)
  plot(vSW, b2, vSW, b1)
  xlim([2150,2550])
  title(sprintf('SW FOV %d', jSW))
  legend('ccast', 'ADL')
  grid on
  subplot(2,1,2)
  plot(vSW, b2 - b1)
  xlim([2150,2550])
  ylim([-2, 2])
  title(sprintf('SW FOV %d ccast minus ADL', jSW))
  grid on

  pause
end

