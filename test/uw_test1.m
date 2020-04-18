%
% quick comparison of UW and ccast, loop on matching obs
%

addpath ../motmsc/time

p1 = './ccast_a4_eng_a2_new_ict/sdr45_npp_HR/2019/062';
% g1 = 'CrIS_SDR_npp_s45_d20190303_t0900080_g091_v20a.mat';
  g1 = 'CrIS_SDR_npp_s45_d20190303_t0000080_g001_v20a.mat';
f1 = fullfile(p1, g1);
d1 = load(f1);

p2 = '/home/motteler/shome/daac_test/SNPPCrISL1B.2/2019/062';
% g2 = 'SNDR.SNPP.CRIS.20190303T0900.m06.g091.L1B.std.v02_05.G.190303163520.nc';
  g2 = 'SNDR.SNPP.CRIS.20190303T0000.m06.g001.L1B.std.v02_05.G.190303081404.nc';
f2 = fullfile(p2, g2);
d2 = read_netcdf_lls(f2);

t1 = d1.geo.FORTime;
t2 = tai2iet(airs2tai(d2.obs_time_tai93));

datestr(iet2dnum(t1(1)))
datestr(iet2dnum(t2(1)))

% match scans from FOR 1
[i1, i2] = seq_match(t1(1,:), t2(1,:), 100);

jFOV = 5;
jFOR = 15;

x1 = d1.vLW;
x2 = d2.wnum_lw;

% loop on matching scans
for i = 1 : length(i1)

  datestr(iet2dnum(t1(1, i1(i))))
  datestr(iet2dnum(t2(1, i2(i))))

  y1 = d1.rLW(:, jFOV, jFOR, i1(i));
  y2 = d2.rad_lw(:, jFOV, jFOR, i2(i));
  b1 = rad2bt(x1, y1);
  b2 = rad2bt(x1, y2);
  plot(x1, b2 - b1)
  axis([650, 1100, -0.2, 0.2])
  grid on
  pause
end

