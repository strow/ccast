%
% cal_flat -- convolve kcarta radiances with kc2cris
% 

addpath ../source

kcdir = '/home/motteler/cris/sergio/JUNK2012';

opt1 = struct;
opt1.resmode = 'hires2';
wlaser = 773.1307;
[instLW, userLW] = inst_params('LW', wlaser, opt1);
[instMW, userMW] = inst_params('MW', wlaser, opt1);
[instSW, userSW] = inst_params('SW', wlaser, opt1);

optLW = struct;  optLW.ng = 0;
optMW = struct;  optMW.ng = 0;
optSW = struct;  optSW.ng = 0;

% e5 filters
optLW.pL =  650; optLW.pH = 1100; optLW.rL = 15; optLW.rH = 20;
optMW.pL = 1200; optMW.pH = 1760; optMW.rL = 30; optMW.rH = 30;
optSW.pL = 2145; optSW.pH = 2560; optSW.rL = 30; optSW.rH = 30;

radLW = []; radMW = []; radSW = [];

for i = 1 : 49

  kcmat = fullfile(kcdir, sprintf('convolved_kcarta%d.mat', i));
  d1 = load(kcmat);
  rkc = d1.r; vkc = d1.w; clear d1

  [rtmp, frqLW] = kc2cris(userLW, rkc, vkc, optLW);
  radLW = [radLW, rtmp];

  [rtmp, frqMW] = kc2cris(userMW, rkc, vkc, optMW);
  radMW = [radMW, rtmp];

  [rtmp, frqSW] = kc2cris(userSW, rkc, vkc, optSW);
  radSW = [radSW, rtmp];

  if mod(i, 10) == 0, fprintf(1, '.'), end
end
fprintf(1, '\n')

save cal_flatX radLW radMW radSW frqLW frqMW frqSW ...
               userLW userMW userSW optLW optMW optSW

