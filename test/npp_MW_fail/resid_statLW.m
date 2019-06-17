%
%  3-way comparison of ccast ref, ccast a4 and noaa a4 SDR data
%
% 1 noaa a4
% 2 ccast ref
% 3 ccast a4
%

addpath ../source
addpath ../motmsc/time
addpath ../motmsc/utils

jFOV = 5;   % select a FOV
jdir = 1;   % select sweep direction (0 or 1)

if true
  dstr = '4 Mar 2019'; fstr = 'pre_fail';
  p1 = '/home/motteler/cris/move_data/npp_scrif/2019/063';
  gn = 'GCRSO-SCRIF_npp_d20190304_t1007039_e1015017_b38080_c20190507191953137970_nobc_ops.h5';
  p2 = './ccast_ref_uw_a2_new_ict/sdr45_npp_HR/2019/063';
  p3 = './ccast_a4_uw_a2_new_ict/sdr45_npp_HR/2019/063';
  gc = 'CrIS_SDR_npp_s45_d20190304_t1006080_g102_v20a.mat';
else
  dstr = '21 Apr 2019'; fstr = 'post_fail';
  p1 = '/home/motteler/cris/move_data/npp_scrif/2019/111';
  gn = 'GCRSO-SCRIF_npp_d20190421_t0944319_e0952297_b38760_c20190506160942680333_noac_ops.h5';
  p2 = './ccast_ref_eng_a2_new_ict/sdr45_npp_HR/2019/111';
  p3 = './ccast_a4_eng_a2_new_ict/sdr45_npp_HR/2019/111';
  gc = 'CrIS_SDR_npp_s45_d20190421_t0948080_g099_v20a.mat';
end

% load noaa data
f1 = fullfile(p1, gn);
d1 = read_SCRIF(f1);
gx = read_GCRSO(f1);

% load ccast data
f2 = fullfile(p2, gc);
f3 = fullfile(p3, gc);
d2 = load(f2);
d3 = load(f3);

t1 = double(gx.FORTime);   % noaa time
t2 = d2.geo.FORTime;       % ccast time
% t3 = d3.geo.FORTime;     % duplicate ccast time
% isequal(t2, t3)

fprintf(1, 'noaa and ccast granule time spans\n')
display([datestr(iet2dnum(t1(1))), '  ', datestr(iet2dnum(t1(end)))])
display([datestr(iet2dnum(t2(1))), '  ', datestr(iet2dnum(t2(end)))])

[j1, j2] = seq_match(t1(:), t2(:));
fprintf(1, 'found %d matches\n', length(j1))

r1 = mod(j1-1, 30) + 1;      % noaa row index
r2 = mod(j2-1, 30) + 1;      % ccast row index
c1 = floor((j1-1)/30) + 1;   % noaa col index
c2 = floor((j2-1)/30) + 1;   % ccast col index
% isequal(double(gx.FORTime(r1, c1)), d2.geo.FORTime(r2, c2))

vLW = d2.vLW;   % ccast LW freq, also used for noaa
vSW = d2.vSW;   % ccast SW freq, also used for noaa

% granule info
i = floor(length(r1)/2);
ts1 = datestr(iet2dnum(gx.FORTime(r1(i), c1(i))));
ts2 = datestr(iet2dnum(d2.geo.FORTime(r2(i), c2(i))));
lat = gx.Latitude(5, r1(i), c1(i));
lon = gx.Longitude(5, r1(i), c1(i));
fmt1 = 'match midpt FOR %d, %s, lat %3.1f lon %3.1f\n';
fprintf(1, fmt1, r1(i), ts1, lat, lon);

% loop on matchups
bt1 = []; bt2 = []; bt3 = [];
cr1 = []; cr2 = []; cr3 = [];
tIET = [];

for i = 1 : length(c1)

% % skip if wrong sweep direction
% if mod(r1(i),2) ~= jdir, continue, end

  rad1 = d1.ES_RealLW(:, jFOV, r1(i), c1(i));
  rad2 = d2.rLW(:, jFOV, r2(i), c2(i));
  rad3 = d3.rLW(:, jFOV, r2(i), c2(i));
  bt1 = [bt1, rad2bt(vLW, rad1)];  % noaa a4
  bt2 = [bt2, rad2bt(vLW, rad2)];  % ccast ref
  bt3 = [bt3, rad2bt(vLW, rad3)];  % ccast a4

  cr1 = [cr1, d1.ES_ImaginaryLW(:, jFOV, r1(i), c1(i))];
  cr2 = [cr2, d2.cLW(:, jFOV, r2(i), c2(i))];
  cr3 = [cr3, d3.cLW(:, jFOV, r2(i), c2(i))];

  tIET = [tIET, d2.geo.FORTime(r2(i), c2(i))];

  if r1(i) ~= r2(i), error('FOR mismatch'), end
end
n1 = length(tIET);

btm1 = mean(bt1, 2);  % noaa a4
btm2 = mean(bt2, 2);  % ccast ref
btm3 = mean(bt3, 2);  % ccast a4
crm1 = mean(cr1, 2);
crm2 = mean(cr2, 2);
crm3 = mean(cr3, 2);
crs1 = std(cr1, 0, 2);
crs2 = std(cr2, 0, 2);
crs3 = std(cr3, 0, 2);

figure(1)
subplot(3,1,1)
plot(vLW, btm1, vLW, btm2, vLW, btm3)
axis([650, 1100, 200, 300])
title(sprintf('%s LW BT mean, FOV %d sweep %d', dstr, jFOV, jdir))
legend('noaa a4', 'ccast ref', 'ccast a4', 'location', 'south')
ylabel('BT (K)')
grid on; zoom on

subplot(3,1,2)
plot(vLW, btm1 - btm2)
axis([650, 1100, -0.2, 0.2])
title('noaa minus ccast ref')
ylabel('dBT (K)')
grid on; zoom on

subplot(3,1,3)
plot(vLW, btm1 - btm3)
axis([650, 1100, -0.2, 0.2])
title('noaa minus ccast a4')
xlabel('wavenumber (cm-1)')
ylabel('dBT (K)')
grid on; zoom on

s1 = sprintf('LW_%s_BT_fov%d_sd%d', fstr, jFOV, jdir);
% saveas(gcf, s1, 'png')

return

figure(2)
subplot(2,1,1)
plot(vLW, crm1, vLW, crm2, vLW, crm3)
axis([650, 1100, -0.25, 0.25])
title(sprintf('%s LW imag resid mean, FOV %d sweep %d', dstr, jFOV, jdir))
legend('noaa a4', 'ccast ref', 'ccast a4')
ylabel('mw sr-1 m-2')
grid on; zoom on

subplot(2,1,2)
plot(vLW, crs1, vLW, crs2, vLW, crs3)
axis([650, 1100, 0, 0.25])
title(sprintf('LW imag resid std, FOV %d sweep %d', jFOV, jdir))
legend('noaa a4', 'ccast ref', 'ccast a4')
ylabel('mw sr-1 m-2')
xlabel('wavenumber (cm-1)')
grid on; zoom on

s2 = sprintf('LW_%s_imag_fov%d_sd%d', fstr, jFOV, jdir);
% saveas(gcf, s2, 'png')

