
d0 = load('sarta_pre_fail_apod0_fov2_sd1.mat');
d1 = load('sarta_pre_fail_apod1_fov2_sd1.mat');
e0 = load('sarta_post_fail_apod0_fov2_sd1.mat');
e1 = load('sarta_post_fail_apod1_fov2_sd1.mat');

% d0 = load('sarta_pre_fail_apod0_fov1_sd1.mat');
% d1 = load('sarta_pre_fail_apod1_fov1_sd1.mat');
% e0 = load('sarta_post_fail_apod0_fov1_sd1.mat');
% e1 = load('sarta_post_fail_apod1_fov1_sd1.mat');

ddpre1 = (d0.btm1 - d0.btm4) - (d1.btm1 - d1.btm4);  % noaa a4
ddpre2 = (d0.btm2 - d0.btm4) - (d1.btm2 - d1.btm4);  % ccast ref
ddpre3 = (d0.btm3 - d0.btm4) - (d1.btm3 - d1.btm4);  % ccast a4

ddpost1 = (e0.btm1 - e0.btm4) - (e1.btm1 - e1.btm4);  % noaa a4
ddpost2 = (e0.btm2 - e0.btm4) - (e1.btm2 - e1.btm4);  % ccast ref
ddpost3 = (e0.btm3 - e0.btm4) - (e1.btm3 - e1.btm4);  % ccast a4

figure(1); clf
subplot(2,1,1)
plot(d0.vx1, ddpre1)
axis([650, 1100, -0.6, 0.6])
title('pre (noaa a4 - sarta) unap - (noaa a4 - sarta) apod');
grid on; zoom on

subplot(2,1,2)
plot(d0.vx1, ddpre3)
axis([650, 1100, -0.6, 0.6])
title('pre (ccast a4 - sarta) unap - (ccast a4 - sarta) apod');
grid on; zoom on
% saveas(gcf, 'ccast_a4_ddif_pre_fail', 'png')

figure(2); clf
subplot(2,1,1)
plot(d0.vx1, ddpost1)
axis([650, 1100, -0.6, 0.6])
title('post (noaa a4 - sarta) unap - (noaa a4 - sarta) apod');
grid on; zoom on

subplot(2,1,2)
plot(d0.vx1, ddpost3)
axis([650, 1100, -0.6, 0.6])
title('post (ccast a4 - sarta) unap - (ccast a4 - sarta) apod');
grid on; zoom on
% saveas(gcf, 'ccast_a4_ddif_post_fail', 'png')

return

figure(3); clf
subplot(2,1,1)
plot(d0.vx1, ddpost1)
axis([650, 1100, -0.6, 0.6])
title('post (noaa a4 - sarta) unap - (noaa a4 - sarta) apod');
grid on; zoom on

subplot(2,1,2)
plot(d0.vx1, ddpost3)
axis([650, 1100, -0.6, 0.6])
title('post (ccast a4 - sarta) unap - (ccast a4 - sarta) apod');
grid on; zoom on
