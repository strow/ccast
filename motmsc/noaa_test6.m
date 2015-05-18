%
% CCAST obs with kcarta convolved radiancs
%
% test5_flat1 - flat calc, sdr60_hr obs
% test5_flat2 - flat calc, c0_Pn_ag obs
% test5_resp1 - resp calc, sdr60_hr obs
% test5_resp2 - resp calc, c0_Pn_ag obs

addpath utils
addpath /home/motteler/matlab/export_fig

% load tests
d1 = load('test5_resp1');
d2 = load('test5_resp2');

%-------------------------
% all FOVs obs minus calc
%-------------------------
frq = d1.vkLW;
calc_mean = mean(d1.bkLW, 2);
obs1_mean = mean(d1.bsLW, 2);
obs2_mean = mean(d2.bsLW, 2);

figure(1); clf
subplot(3,1,1)
plot(frq, obs1_mean - calc_mean)
axis([650, 1100, -2, 2])
title('sdr60-hr minus calc all FOVs')
ylabel('dBT')
grid on; zoom on

subplot(3,1,2)
plot(frq, obs2_mean - calc_mean)
axis([650, 1100, -2, 2])
title('c0-Pn-ag minus calc all FOVs')
ylabel('dBT')
grid on; zoom on

subplot(3,1,3)
plot(frq, obs2_mean - obs1_mean)
axis([650, 1100, -2, 2])
title('c0-Pn-ag minus sdr60-hr all FOVs')
ylabel('dBT')
grid on; zoom on

return

%-----------------------------
% selected FOV obs minus calc
%------------------------------
jFOV = input('select a FOV > ');
ix = find(d1.ifov == jFOV);
calc_mean = mean(d1.bkLW(:, ix), 2);
obs1_mean = mean(d1.bsLW(:, ix), 2);
obs2_mean = mean(d2.bsLW(:, ix), 2);

figure(2); clf
subplot(3,1,1)
plot(frq, obs1_mean - calc_mean)
axis([650, 1100, -2, 2])
title(sprintf('sdr60-hr minus calc FOV %d', jFOV))
ylabel('dBT')
grid on; zoom on

subplot(3,1,2)
plot(frq, obs2_mean - calc_mean)
axis([650, 1100, -2, 2])
title(sprintf('c0-Pn-ag minus calc FOV %d', jFOV))
ylabel('dBT')
grid on; zoom on

subplot(3,1,3)
plot(frq, obs2_mean - obs1_mean)
axis([650, 1100, -2, 2])
title(sprintf('c0-Pn-ag minus sdr60-hr FOV %d', jFOV))
ylabel('dBT')
grid on; zoom on

