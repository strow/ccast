%
% quick comparison of ccast and noaa data matchup means
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

i = 1;
ts1 = datestr(iet2dnum(d2.FORTime(r1(i), c1(i))));
ts2 = datestr(iet2dnum(d3.geo.FORTime(r2(i), c2(i))));
lat = d2.Latitude(jLW, r1(i), c1(i));
lon = d2.Longitude(jLW, r1(i), c1(i));
fmt1 = 'FOR %d, %s, lat %3.1f lon %3.1f\n';
fprintf(1, fmt1, r1(i), ts1, lat, lon);

vLW = d3.vLW;
vSW = d3.vSW;
nLW = length(vLW);
nSW = length(vSW);
nmatch = length(c1);

rLW1 = zeros(nLW, 9, nmatch);
rLW3 = zeros(nLW, 9, nmatch);
rSW1 = zeros(nSW, 9, nmatch);
rSW3 = zeros(nSW, 9, nmatch);

for i = 1 : length(c1)
  rLW1(:,:,i) = d1.ES_RealLW(:, :, r1(i), c1(i));
  rLW3(:,:,i) = d3.rLW(:, :, r2(i), c2(i));
  rSW1(:,:,i) = d1.ES_RealSW(:, :, r1(i), c1(i));
  rSW3(:,:,i) = d3.rSW(:, :, r2(i), c2(i));
end

rmLW1 = mean(rLW1, 3);
rmLW3 = mean(rLW3, 3);
rmSW1 = mean(rSW1, 3);
rmSW3 = mean(rSW3, 3);

bmLW1 = real(rad2bt(vLW, rmLW1));
bmLW3 = real(rad2bt(vLW, rmLW3));
bmSW1 = real(rad2bt(vSW, rmSW1));
bmSW3 = real(rad2bt(vSW, rmSW3));

figure(1)
subplot(2,1,1)
jLW = 5;
plot(vLW, bmLW1(:,jLW), vLW, bmLW3(:,jLW))
xlim([650, 1100])
title(sprintf('LW FOV %d', jLW))
legend('ccast', 'ADL', 'location', 'south')
grid on

subplot(2,1,2)
plot(vLW, bmLW3 - bmLW1)
xlim([650, 1100])
ylim([-1, 1])
  title('LW all FOVs ccast minus noaa')
% title(sprintf('LW FOV %d ccast minus ADL', jLW))
grid on

figure(2)
subplot(2,1,1)
jSW = 5;
plot(vSW, bmSW1(:,jSW), vSW, bmSW3(:,jSW))
xlim([2150, 2550])
title(sprintf('SW FOV %d', jSW))
legend('ccast', 'ADL', 'location', 'southeast')
grid on

subplot(2,1,2)
plot(vSW, bmSW3 - bmSW1)
xlim([2150, 2550])
ylim([-1, 1])
  title('SW all FOVs ccast minus noaa')
% title(sprintf('SW FOV %d ccast minus ADL', jSW))
grid on

figure(3)
ix = 1:9
subplot(2,1,1)
plot(vSW, bmSW3(:,ix) - bmSW1(:,ix))
xlim([2150, 2550])
ylim([-1, 1])
title('SW all FOVs ccast minus noaa')
grid on

ix = 5;
subplot(2,1,2)
plot(vSW, bmSW3(:,ix) - bmSW1(:,ix))
xlim([2150, 2550])
ylim([-1, 1])
title('SW FOV 5 ccast minus noaa')
grid on

figure(4)
ix = [2,4,6,8];
subplot(2,1,1)
plot(vSW, bmSW3(:,ix) - bmSW1(:,ix))
xlim([2150, 2550])
ylim([-1, 1])
title('SW side FOVs ccast minus noaa')
grid on

ix = [1,3,7,9]
subplot(2,1,2)
plot(vSW, bmSW3(:,ix) - bmSW1(:,ix))
xlim([2150, 2550])
ylim([-1, 1])
title('SW corner FOVs ccast minus noaa')
grid on

