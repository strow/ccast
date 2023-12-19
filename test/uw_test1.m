%
% quick comparison of UW and ccast, loop on matching obs
%

addpath /home/motteler/cris/ccast/motmsc/time
addpath /home/motteler/shome/chirp_test/

% p1 = '/asl/cris/ccast/sdr45_j01_HR/2023/250';
% g1 = 'CrIS_SDR_j01_s45_d20230907_t2312080_g233_v20d.mat';
  p1 = '/asl/cris/ccast_v3/sdr45_j02_HR/2023/058';
  g1 = 'CrIS_SDR_j02_s45_d20230227_t2030010_g206_v21a.mat';

f1 = fullfile(p1, g1);
d1 = load(f1);

% p2 = '/asl/cris/nasa_l1b/j01/2023/250';
% g2 = 'SNDR.J1.CRIS.20230907T2312.m06.g233.L1B.std.v4_0dev20230407.W.230908044537.nc';
  p2 = '/asl/cris/nasa_l1b/j02/2023/058';
  g2 = 'SNDR.J2.CRIS.20230227T2030.m06.g206.L1B.std.v4_0dev20230306.W.230306204846.nc';

f2 = fullfile(p2, g2);
d2 = read_netcdf_h5(f2);

t1 = d1.geo.FORTime;
t2 = tai2iet(airs2tai(d2.obs_time_tai93));

datestr(iet2dnum(t1(1)))
datestr(iet2dnum(t2(1)))

% match scans from FOR 1
[i1, i2] = seq_match(t1(1,:), t2(1,:), 100);

jFOV = 5;
jFOR = 15;

v1LW = d1.vLW;
v2LW = d2.wnum_lw;
v1MW = d1.vMW;
v2MW = d2.wnum_mw;
v1SW = d1.vSW;
v2SW = d2.wnum_sw;

% loop on matching scans
for i = 1 : length(i1)

  datestr(iet2dnum(t1(1, i1(i))))
  datestr(iet2dnum(t2(1, i2(i))))

  figure(1)
  y1 = d1.rLW(:, jFOV, jFOR, i1(i));
  y2 = d2.rad_lw(:, jFOV, jFOR, i2(i));
  b1 = rad2bt(v1LW, y1);
  b2 = rad2bt(v2LW, y2);
  plot(v1LW, b2 - b1)
  axis([650, 1100, -0.2, 0.2])
  grid on

  figure(2)
  y1 = d1.rMW(:, jFOV, jFOR, i1(i));
  y2 = d2.rad_mw(:, jFOV, jFOR, i2(i));
  b1 = rad2bt(v1MW, y1);
  b2 = rad2bt(v2MW, y2);
  plot(v1MW, b2 - b1)
% axis([650, 1100, -0.2, 0.2])
  grid on

  figure(3)
  y1 = d1.rSW(:, jFOV, jFOR, i1(i));
  y2 = d2.rad_sw(:, jFOV, jFOR, i2(i));
  b1 = rad2bt(v1SW, y1);
  b2 = rad2bt(v2SW, y2);
  plot(v1SW, b2 - b1)
% axis([650, 1100, -0.2, 0.2])
  grid on

  pause
end

