% 
% ils_test6 -- test fix for limit a -> 0
%

% select a FOV
iFOV = 5;

% channel for comparison plots
ichan = 100;  

% inst_params options
band = 'SW';
wlaser =  773.1;
opt1 = struct;
opt1.resmode = 'lowres';
[inst1, user] = inst_params(band, wlaser, opt1);
inst2 = inst1;

% tweak iFOV angle
  sf = 1e8;
  inst1.foax(iFOV) = 0;
% inst1.foax(iFOV) = inst1.foax(iFOV) / sf;
  inst2.foax(iFOV) = inst2.foax(iFOV) / sf;

% newILS options
opt2 = struct;
opt2.wrap = 'psinc n';
opt2.narc = 1000;

% call new and old functions
ils1 =  newILS(iFOV, inst1, inst1.freq(ichan), inst1.freq, opt2);
ils2 = newILS2(iFOV, inst2, inst2.freq(ichan), inst2.freq, opt2);

isequal(ils1, ils2)

figure(1); clf
plot(inst1.freq, ils1 - ils2)
title('new minus old')

