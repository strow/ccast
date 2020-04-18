%
% 3-way comparison of ccast, noaa, and uw, loop on matching obs
%

addpath ../motmsc/time
addpath ../motmsc/utils

% choose a FOV and FOR
jFOV = 1;
jFOR = 15;

% ccast granule
p1 = './ccast_a4_eng_a2_new_ict/sdr45_npp_HR/2019/063';
g1 = 'CrIS_SDR_npp_s45_d20190304_t1006080_g102_v20a.mat';
f1 = fullfile(p1, g1);
d1 = load(f1);

% noaa granule
p2 = '/home/motteler/cris/move_data/npp_scrif/2019/063';
g2 = 'GCRSO-SCRIF_npp_d20190304_t1007039_e1015017_b38080_c20190507191953137970_nobc_ops.h5';
f2 = fullfile(p2, g2);
d2 = read_SCRIF(f2);
d2g = read_GCRSO(f2);

% uw granule
p3 = '/home/motteler/shome/daac_test/SNPPCrISL1B.2/2019/063';
g3 = 'SNDR.SNPP.CRIS.20190304T1006.m06.g102.L1B.std.v02_05.G.190304194948.nc';
f3 = fullfile(p3, g3);
d3 = read_netcdf_lls(f3);

t1 = d1.geo.FORTime;
t2 = double(d3g.FORTime);
t3 = tai2iet(airs2tai(d3.obs_time_tai93));

fprintf(1, 'granule start times\n')
datestr(iet2dnum(t1(1)))
datestr(iet2dnum(t2(1)))
datestr(iet2dnum(t3(1)))

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
fprintf(1, '%d scan matchups ', length(i1))
j = floor(length(i1)/2);
mt = datestr(iet2dnum(t1(jFOR, i1(j))));
mlat = d1.geo.Latitude(jFOV, jFOR, i1(j));
mlon = d1.geo.Longitude(jFOV, jFOR, i1(j));
fprintf(1, 'midpt %s, lat %3.1f lon %3.1f\n', mt, mlat, mlon)

%---------  
% SW test
%---------  

% ccast and uw frequency
v1 = d1.vSW;
v3 = d3.wnum_sw;

% loop on matching scans
for i = 1 : length(i1)

% datestr(iet2dnum(t1(1, i1(i))))
% datestr(iet2dnum(t2(1, i2(i))))
% datestr(iet2dnum(t3(1, i3(i))))

  r1 = d1.rSW(:, jFOV, jFOR, i1(i));
  r2 = d2.ES_RealSW(:, jFOV, jFOR, i2(i));
  r3 = d3.rad_sw(:, jFOV, jFOR, i3(i));

  b1 = rad2bt(v1, r1);    % ccast
  b2 = rad2bt(v1, r2);    % noaa
  b3 = rad2bt(v1, r3);    % uw

  subplot(3,1,1)
  plot(v1, b2 - b1)
  axis([2150, 2550, -2, 2])
% axis([1200, 1750, -1, 1])
  title('noaa minus ccast')
  grid on

  subplot(3,1,2)
  plot(v1, b3 - b1)
  axis([2150, 2550, -2, 2])
% axis([1200, 1750, -1, 1])
  title('uw minus ccast')
  grid on

  subplot(3,1,3)
  plot(v1, b3 - b2)
  axis([2150, 2550, -2, 2])
% axis([1200, 1750, -1, 1])
  title('uw minus noaa')
  grid on

  pause
end

%---------
% LW test
%---------

% ccast and uw frequency
v1 = d1.vLW;
v3 = d3.wnum_lw;

% loop on matching scans
for i = 1 : length(i1)

  datestr(iet2dnum(t1(1, i1(i))))
  datestr(iet2dnum(t2(1, i2(i))))
  datestr(iet2dnum(t3(1, i3(i))))

  r1 = d1.rLW(:, jFOV, jFOR, i1(i));
  r2 = d2.ES_RealLW(:, jFOV, jFOR, i2(i));
  r3 = d3.rad_lw(:, jFOV, jFOR, i3(i));

  b1 = rad2bt(v1, r1);    % ccast
  b2 = rad2bt(v1, r2);    % noaa
  b3 = rad2bt(v1, r3);    % uw

  subplot(3,1,1)
  plot(v1, b2 - b1)
  axis([650, 1100, -0.2, 0.2])
  title('noaa minus ccast')
  grid on

  subplot(3,1,2)
  plot(v1, b3 - b1)
  axis([650, 1100, -0.2, 0.2])
  title('uw minus ccast')
  grid on

  subplot(3,1,3)
  plot(v1, b3 - b2)
  axis([650, 1100, -0.2, 0.2])
  title('uw minus noaa')
  grid on

  pause
end



