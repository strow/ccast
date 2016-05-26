%
% compare ccast minus noaa with flat minus response ref truth
%
% cf.bobs nr.bobs from cal_plot2.m
% flat_bt and resp_bt from cal_test1.

figure(8)    
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(2,1,1)
set(gcf, 'DefaultAxesColorOrder', fcolor);
plot(cf.vobs, cf.bobs - nr.bobs)
axis([600, 2600, -0.6, 0.6])
title('ccast obs minus noaa obs, all FOVs')
xlabel('wavenumber')
ylabel('dBT')
grid on; zoom on

subplot(2,1,2)
plot(vobs, flat_bt - resp_bt);
axis([600, 2600, -0.4, 0.4])
title('flat calc minus resp calc')
ylabel('dBT')
grid on; zoom on
subplot(2,1,1)
axis([600, 2600, -0.6, 0.6])
axis([600, 2600, -0.4, 0.4])

% addpath /home/motteler/matlab/export_fig
% export_fig('obs_calc_diffs.pdf','-m2', '-transparent')
