%
% resp_test4 -- calibration equation tests
%

addpath ../source

% kcarta test data
kcdir = '/home/motteler/cris/sergio/JUNK2012/';
flist =  dir(fullfile(kcdir, 'convolved_kcart*.mat'));

% choose a kcarta file
ip = 1;
d1 = load(fullfile(kcdir, flist(ip).name));
vkc = d1.w(:);
rkc = d1.r(:);
rbb = bt2rad(vkc, 280);

% get CrIS user struct
opt1 = struct;
opt1.user_res = 'hires';
opt1.inst_res = 'hires3';
wlaser = 773.13;
[inst, user] = inst_params('LW', wlaser, opt1);

% get normalized responsivity
load resp_filt

switch upper(user.band)
 case 'LW', resp_filt = filt_lw; resp_freq = freq_lw;
 case 'MW', resp_filt = filt_mw; resp_freq = freq_mw;
 case 'SW', resp_filt = filt_sw; resp_freq = freq_sw;
end

% filter limits define the band span
fv1 = resp_freq(1); fv2 = resp_freq(end);
ix = find(fv1 <= vkc & vkc <= fv2);
rkc = rkc(ix, :);
rbb = rbb(ix, :);
vkc = vkc(ix);

% interpolate the filter to the kcarta grid
rhoHR = interp1(resp_freq, resp_filt, vkc, 'spline');

% apply the high res filter
rho_rkc = rkc .* rhoHR;
rho_rbb = rbb .* rhoHR;

% resamle to low res
dv2 = 0.625;
[F_rkc, vLR] = finterp(rkc, vkc, dv2);
[F_rbb, vLR] = finterp(rbb, vkc, dv2);
[F_rho_rkc, vLR] = finterp(rho_rkc, vkc, dv2);
[F_rho_rbb, vLR] = finterp(rho_rbb, vkc, dv2);
[F_rho, vLR] = finterp(rhoHR, vkc, dv2);

% F rho rBB vs rho F rBB
b1 = real(rad2bt(vLR, F_rho_rbb));
b2 = real(rad2bt(vLR, F_rho .* F_rbb));

figure(1)
subplot(2,1,1)
plot(vLR, b1, vLR, b2)
axis([650, 1100, 180, 320])
title('rho * rBB')
legend('F rho rBB', 'rho F rBB', 'location', 'south')
grid on; zoom on

subplot(2,1,2)
plot(vLR, b1 - b2)
axis([650, 1100, -0.1, 0.1])
title('F rho rBB minus rho F rBB')
grid on; zoom on
saveas(gcf, 'BB_comm', 'png')

% F rho rES vs rho F rES
b3 = real(rad2bt(vLR, F_rho_rkc));
b4 = real(rad2bt(vLR, F_rho .* F_rkc));

figure(2)
subplot(2,1,1)
plot(vLR, b3, vLR, b4)
axis([650, 1100, 140, 320])
title('rho * rES')
legend('F rho rES', 'rho F rES', 'location', 'south')
grid on; zoom on

subplot(2,1,2)
plot(vLR, b3 - b4)
axis([650, 1100, -0.5, 0.5])
title('F rho rES minus rho F rES')
grid on; zoom on
saveas(gcf, 'ES_comm', 'png')

return

% direct calculation of low res BB
rbbLR = bt2rad(vLR, 280);

% Larrabee's reference ratio
rLR1 = rbbLR .* F_rho_rkc ./ F_rho_rbb;

% UW responsivity definition
rLR2 = F_rho_rkc ./ F_rho;

bLR1 = real(rad2bt(vLR, rLR1));
bLR2 = real(rad2bt(vLR, rLR2));

figure(3)
subplot(2,1,1)
plot(vLR, bLR1, vLR, bLR2)
axis([650, 1100, 200, 300])
title('LLS and UW resp ref truth')
legend('LLS resp', 'UW resp', 'location', 'south')

subplot(2,1,2)
plot(vLR, bLR1 - bLR2)
axis([650, 1100, -0.1, 0.1])
title('LLS minus UW resp ref truth')

b1 = real(rad2bt(vLR, F_rho_rbb));
b2 = real(rad2bt(vLR, F_rho .* rbbLR));

figure(4)
subplot(2,1,1)
plot(vLR, b1, vLR, b2)
axis([650, 1100, 200, 300])
title('rho * rBB')
legend('F rho rbb', 'F rho * rbbLR', 'location', 'south')

subplot(2,1,2)
plot(vLR, b1 - b2)
axis([650, 1100, -0.1, 0.1])
title('F rho rbb minus F rho * rbbLR')

