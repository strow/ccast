%
% quick comparison of ccast and noaa data
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

p2 = '/asl/data/cris/ccast/SDR_j01_s45/2018/008';
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

jFOV = 9;
x1 = d2.vLW;
for i = 1 : length(c1)
  ts1 = datestr(iet2dnum(gx.FORTime(r1(i), c1(i))));
  ts2 = datestr(iet2dnum(d2.geo.FORTime(r2(i), c2(i))));
  fprintf(1, 'FOV %d FOR %d, %s\n', jFOV, r1(i), ts1)
  y1 = d1.ES_RealLW(:, jFOV, r1(i), c1(i));
  y2 = d2.rLW(:, jFOV, r2(i), c2(i));
  b1 = rad2bt(x1, y1);
  b2 = rad2bt(x1, y2);
  plot(x1, b1 - b2)
  axis([650, 1100, -1, 1])
  title('ADL minus ccast')
  grid on
  pause
end

