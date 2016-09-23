%
% resp_test6 -- sample flat, flat + 20, and resp ref truth
%

addpath ../source
addpath ./utils

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
[instLW, userLW] = inst_params('LW', wlaser, opt1);
[instMW, userMW] = inst_params('MW', wlaser, opt1);
[instSW, userSW] = inst_params('SW', wlaser, opt1);

% standard flat CrIS ref truth
[rLWflat, vLW] = kc2cris(userLW, rkc, vkc);
[rMWflat, vMW] = kc2cris(userMW, rkc, vkc);
[rSWflat, vSW] = kc2cris(userSW, rkc, vkc);

% flat CrIS with extended passband
pX = 20;  % passband extension
opt2LW = struct; opt2LW.rL = 20; opt2LW.rH = 20;
opt2LW.pL = instLW.pL - pX; opt2LW.pH = instLW.pH + pX;

opt2MW = struct; opt2MW.rL = 30; opt2MW.rH = 30;
opt2MW.pL = instMW.pL - pX; opt2MW.pH = instMW.pH + pX;

opt2SW = struct; opt2SW.rL = 30; opt2SW.rH = 30;
opt2SW.pL = instSW.pL - pX; opt2SW.pH = instSW.pH + pX;

[rLWwide, vLW] = kc2cris(userLW, rkc, vkc, opt2LW);
[rMWwide, vMW] = kc2cris(userMW, rkc, vkc, opt2MW);
[rSWwide, vSW] = kc2cris(userSW, rkc, vkc, opt2SW);

% CrIS with UW-style responsivity
[rLWresp, vLW] = kc2resp(userLW, rkc, vkc);
[rMWresp, vMW] = kc2resp(userMW, rkc, vkc);
[rSWresp, vSW] = kc2resp(userSW, rkc, vkc);

% save resp_test6 vLW rLWflat rLWwide rLWresp ...
%                 vMW rMWflat rMWwide rMWresp ...
%                 vSW rSWflat rSWwide rSWresp 

% show differences as brightness temps
bLWresp = real(rad2bt(vLW, rLWresp));
bMWresp = real(rad2bt(vMW, rMWresp));
bSWresp = real(rad2bt(vSW, rSWresp));
bLWflat = real(rad2bt(vLW, rLWflat));
bMWflat = real(rad2bt(vMW, rMWflat));
bSWflat = real(rad2bt(vSW, rSWflat));
bLWwide = real(rad2bt(vLW, rLWwide));
bMWwide = real(rad2bt(vMW, rMWwide));
bSWwide = real(rad2bt(vSW, rSWwide));

% plot LW diffs
figure(1); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(3,1,1)
plot(vLW, bLWflat - bLWwide)
axis([650, 1100, -0.5, 0.5])
title('LW flat minus flat+20'); 
grid on; zoom on

subplot(3,1,2)
plot(vLW, bLWresp - bLWwide)
axis([650, 1100, -0.5, 0.5])
title('LW resp minus flat+20'); 
grid on; zoom on

subplot(3,1,3)
plot(vLW, bLWresp - bLWflat)
axis([650, 1100, -0.5, 0.5])
title('LW resp minus flat'); 
grid on; zoom on
% saveas(gcf, 'LW_truth_diff', 'fig')

% plot MW diffs
figure(2); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(3,1,1)
plot(vMW, bMWflat - bMWwide)
axis([1210, 1740, -0.5, 0.5]) 
title('MW flat minus flat+20'); 
grid on; zoom on

subplot(3,1,2)
plot(vMW, bMWresp - bMWwide)
axis([1210, 1740, -0.5, 0.5]) 
title('MW resp minus flat+20'); 
grid on; zoom on

subplot(3,1,3)
plot(vMW, bMWresp - bMWflat)
axis([1210, 1740, -0.5, 0.5]) 
title('MW resp minus flat'); 
grid on; zoom on
% saveas(gcf, 'MW_truth_diff', 'fig')

% plot SW diffs
figure(3); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(3,1,1)
plot(vSW, bSWflat - bSWwide)
axis([2155, 2550, -0.5, 0.5]) 
title('SW flat minus flat+20'); 
grid on; zoom on

subplot(3,1,2)
plot(vSW, bSWresp - bSWwide)
axis([2155, 2550, -0.5, 0.5]) 
title('SW resp minus flat+20'); 
grid on; zoom on

subplot(3,1,3)
plot(vSW, bSWresp - bSWflat)
axis([2155, 2550, -0.5, 0.5]) 
title('SW resp minus flat'); 
grid on; zoom on
% saveas(gcf, 'SW_truth_diff', 'fig')

