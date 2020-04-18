%
% quick look at one ccast granule
%

p1 = '/asl/cris/ccast/sdr45_npp_HR/2019/176';
gran = 'CrIS_SDR_npp_s45_d20190625_t0024080_g005_v20a.mat';

f1 = fullfile(p1, gran);
d1 = load(f1);

t1 = d1.geo.FORTime;
[datestr(iet2dnum(t1(1))), '  ', datestr(iet2dnum(t1(end)))]
[d1.geo.Latitude(1), d1.geo.Longitude(1)]

x1 = d1.vLW;
y1 = mean(d1.rLW(:, :, :), 3);
b1 = rad2bt(x1, y1);

figure(1); clf
subplot(2,1,1)
plot(x1, b1)
axis([650, 1150, 200, 300])
title('all fovs')
set(gcf, 'DefaultAxesColorOrder', fovcolors);
legend(fovnames, 'location', 'eastoutside')
grid on

subplot(2,1,2)
plot(x1, b1 - b1(:, 5))
axis([650, 1150, -1, 1])
title('all fovs minus fov 5')
set(gcf, 'DefaultAxesColorOrder', fovcolors);
legend(fovnames, 'location', 'eastoutside')
grid on

x1 = d1.vMW;
y1 = mean(d1.rMW(:, :, :), 3);
b1 = rad2bt(x1, y1);

figure(2); clf
subplot(2,1,1)
plot(x1, b1)
% axis([650, 1150, 200, 300])
title('all fovs')
set(gcf, 'DefaultAxesColorOrder', fovcolors);
legend(fovnames, 'location', 'eastoutside')
grid on

subplot(2,1,2)
plot(x1, b1 - b1(:, 5))
% axis([650, 1150, -1, 1])
title('all fovs minus fov 5')
set(gcf, 'DefaultAxesColorOrder', fovcolors);
legend(fovnames, 'location', 'eastoutside')
grid on

