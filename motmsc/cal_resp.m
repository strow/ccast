%
% cal_resp -- convolve kcarta radiances with kc2resp
% 

addpath ../source
addpath utils

kcdir = '/asl/s1/motteler/kctest5/kcdata';

opts = struct;
opts.inst_res = 'hires3';
opts.user_res = 'hires';
wlaser = 773.1307;
[instLW, userLW] = inst_params('LW', wlaser, opts);
[instMW, userMW] = inst_params('MW', wlaser, opts);
[instSW, userSW] = inst_params('SW', wlaser, opts);

ngc = 0;
radLW = []; radMW = []; radSW = [];

for i = 1 : 3782

  kcmat = fullfile(kcdir, sprintf('kc%04d.mat', i));
  d1 = load(kcmat);
  rkc = d1.radkc; vkc = d1.freqkc; clear d1

  [rtmp, frqLW] = kc2resp(userLW, rkc, vkc, ngc);
  radLW = [radLW, rtmp];

  [rtmp, frqMW] = kc2resp(userMW, rkc, vkc, ngc);
  radMW = [radMW, rtmp];

  [rtmp, frqSW] = kc2resp(userSW, rkc, vkc, ngc);
  radSW = [radSW, rtmp];

  if mod(i, 100) == 0, fprintf(1, '.'), end
end
fprintf(1, '\n')

save cal_resp radLW radMW radSW frqLW frqMW frqSW userLW userMW userSW

