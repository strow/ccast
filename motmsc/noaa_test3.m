%
% noaa_test3 -- convolve a set of kcarta radiances
% 
addpath ../source
addpath /home/motteler/cris/airs_decon/source

kcdir = '/asl/s1/motteler/data/noaa_test';

opts = struct;
opts.resmode = 'hires2';
wlaser = 773.1307;[instLW, userLW] = inst_params('LW', wlaser, opts);
[instLW, userLW] = inst_params('LW', wlaser, opts);
[instMW, userMW] = inst_params('MW', wlaser, opts);
[instSW, userSW] = inst_params('SW', wlaser, opts);

ngc = 2;
radLW = [];
radMW = [];
radSW = [];

for i = 1 : 2479

  kcmat = fullfile(kcdir, sprintf('kc%d.mat', i));
  d1 = load(kcmat);
  rkc = d1.radkc; vkc = d1.freqkc; clear d1

  [rad1, frqLW] = kc2resp(userLW, rkc, vkc, ngc);
  radLW = [radLW, rad1];

  [rad1, frqMW] = kc2resp(userMW, rkc, vkc, ngc);
  radMW = [radMW, rad1];

  [rad1, frqSW] = kc2resp(userSW, rkc, vkc, ngc);
  radSW = [radSW, rad1];

  if mod(i, 100) == 0, fprintf(1, '.'), end
end
fprintf(1, '\n')

save test3_resp radLW radMW radSW frqLW frqMW frqSW userLW userMW userSW

