%
% tabulated emissivity for highres ICT model
%

clear all

wlaser = 773.1302;

% get sci and eng data for Feb 23
load /home/motteler/cris/data/2012/daily/allsci20120223.mat

% browse the ICT data, should be all the same
% for i = 1 : 200                                        
%   plot(alleng(i).ICT_Param.Band(1).ICT.EffEmissivity.Pts)
%  i, pause
% end
  
i = 20;
e1lo = alleng(i).ICT_Param.Band(1).ICT.EffEmissivity.Pts;
e2lo = alleng(i).ICT_Param.Band(2).ICT.EffEmissivity.Pts;
e3lo = alleng(i).ICT_Param.Band(3).ICT.EffEmissivity.Pts;

i2lo = inst_paramsLR('MW', wlaser);
i3lo = inst_paramsLR('SW', wlaser);

i2hi = inst_paramsHR('MW', wlaser);
i3hi = inst_paramsHR('SW', wlaser);

e1hi = e1lo;
e2hi = interp1(i2lo.freq, e2lo, i2hi.freq, 'spline');
e3hi = interp1(i3lo.freq, e3lo, i3hi.freq, 'spline');

figure(1)
plot(i2lo.freq, e2lo,i2hi.freq, e2hi)
title('MW lo and hi res ICT emissivity')
legend('lo res', 'hi res')
zoom on
grid

figure(2)
plot(i2lo.freq, e2lo,i2hi.freq, e2hi)
title('SW lo and hi res ICT emissivity')
legend('lo res', 'hi res')
zoom on
grid

whos e1hi e2hi e3hi 

save inst_data/emissHR e1hi e2hi e3hi

