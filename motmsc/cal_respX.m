%
% cal_resp -- convolve kcarta radiances with kc2resp
% 

addpath ../source
addpath utils

kcdir = '/home/motteler/cris/sergio/JUNK2012';

opts = struct;
opts.resmode = 'hires2';
wlaser = 773.1307;
[instLW, userLW] = inst_params('LW', wlaser, opts);
[instMW, userMW] = inst_params('MW', wlaser, opts);
[instSW, userSW] = inst_params('SW', wlaser, opts);

ngc = 0;
radLW = []; radMW = []; radSW = [];

for i = 1 : 49

  kcmat = fullfile(kcdir, sprintf('convolved_kcarta%d.mat', i));
  d1 = load(kcmat);
  rkc = d1.r; vkc = d1.w; clear d1

  [rtmp, frqLW] = kc2resp(userLW, rkc, vkc, ngc);
  radLW = [radLW, rtmp];

  [rtmp, frqMW] = kc2resp(userMW, rkc, vkc, ngc);
  radMW = [radMW, rtmp];

  [rtmp, frqSW] = kc2resp(userSW, rkc, vkc, ngc);
  radSW = [radSW, rtmp];

  if mod(i, 10) == 0, fprintf(1, '.'), end
end
fprintf(1, '\n')

save cal_respX radLW radMW radSW frqLW frqMW frqSW userLW userMW userSW

