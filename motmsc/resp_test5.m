%
% resp_test5 -- show R fHR rHR vs fLR R rHR
%

addpath /home/motteler/matlab/export_fig
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

% standard flat low res CrIS spectra
opt2 = struct;
opt2.ngc = 2;
[r1, v1] = kc2cris(user, rkc, vkc, opt2);

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
[R_rkc, vLR] = finterp(rkc, vkc, dv2);
[R_rbb, vLR] = finterp(rbb, vkc, dv2);
[R_rho_rkc, vLR] = finterp(rho_rkc, vkc, dv2);
[R_rho_rbb, vLR] = finterp(rho_rbb, vkc, dv2);
[R_rho, vLR] = finterp(rhoHR, vkc, dv2);

% R rho rIT vs rho R rIT
b1 = real(rad2bt(vLR, R_rho_rbb));
b2 = real(rad2bt(vLR, R_rho .* R_rbb));

figure(1)
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(2,1,1)
plot(vLR, b1, vLR, b2)
axis([650, 1100, 180, 320])
title('R rho rIT and rho R rIT')
legend('R rho rIT', 'rho R rIT', 'location', 'south')
ylabel('BT, K')
grid on; zoom on

subplot(2,1,2)
plot(vLR, b1 - b2)
axis([650, 1100, -0.1, 0.1])
title('R rho rIT minus rho R rIT')
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on
% saveas(gcf, 'BB_comm', 'png')
% export_fig('BB_comm.pdf', '-m2', '-transparent')

% R rho rES vs rho R rES
b3 = real(rad2bt(vLR, R_rho_rkc));
b4 = real(rad2bt(vLR, R_rho .* R_rkc));

figure(2)
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(2,1,1)
plot(vLR, b3, vLR, b4)
axis([650, 1100, 140, 320])
title('R rho rES and rho R rES')
legend('R rho rES', 'rho R rES', 'location', 'south')
ylabel('BT, K')
grid on; zoom on

subplot(2,1,2)
plot(vLR, b3 - b4)
axis([650, 1100, -0.5, 0.5])
title('R rho rES minus rho R rES')
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on
% saveas(gcf, 'ES_comm', 'png')
% export_fig('ES_comm.pdf', '-m2', '-transparent')

return

% **** earlier tests below ****

% direct calculation of low res BB
rbbLR = bt2rad(vLR, 280);

% Larrabee's reference ratio
rLR1 = rbbLR .* R_rho_rkc ./ R_rho_rbb;

% UW responsivity definition
rLR2 = R_rho_rkc ./ R_rho;

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

b1 = real(rad2bt(vLR, R_rho_rbb));
b2 = real(rad2bt(vLR, R_rho .* rbbLR));

figure(4)
subplot(2,1,1)
plot(vLR, b1, vLR, b2)
axis([650, 1100, 200, 300])
title('rho * rIT')
legend('R rho rbb', 'R rho * rbbLR', 'location', 'south')

subplot(2,1,2)
plot(vLR, b1 - b2)
axis([650, 1100, -0.1, 0.1])
title('R rho rbb minus R rho * rbbLR')

% % interpolate the filter to the CrIS user grid
% rhoLR = interp1(resp_freq, resp_filt, v1, 'spline');
% 
% r2 = rhoLR .* r1;
% 
% opt3 = struct;
% opt3.info = 1;
% [r3, f3] = finterp(r2, v1, user.dv, opt3);
% r3 = real(r3);
% 
% r4 = r3 ./ rhoLR;
% 
% b1 = real(rad2bt(v1, r1));
% b2 = real(rad2bt(v1, r2));
% b3 = real(rad2bt(v1, r3));
% 
% % plot(frq1, b1, frq1, b2)
% % legend('cris flat', 'flat * rho')
% 
% % r1 - cris user grid from kc2cris
% % r2 = rho * r1
% % r3 = R(r2)

