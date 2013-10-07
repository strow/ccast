
% get path to pcorr
addpath zold2

load /kale/s2/cris/ccast/sdr60/2013/092/DMP_d20130402_t0722554.mat

[r2, t0] = pcorr2(squeeze(rcLW(:,5,find(igmSDR == 0))));
[r2, t1] = pcorr2(squeeze(rcLW(:,5,find(igmSDR == 1))));

tm0 = mean(t0, 2);
tm1 = mean(t1, 2);

figure(1); clf
plot(instLW.freq, tm0, instLW.freq, tm1)
title(['forward and reverse mean phase for ', strrep(rid, '_', ' ')])
legend('sweep dir 0', 'sweep dir 1')
xlabel('wavenumber')
ylabel('phase')
grid on; zoom on

saveas(gcf, 'mean_phase', 'fig')

figure(2); clf
plot(instLW.freq, tm0 - tm1)
title(['forward and reverse mean phase diff for ', strrep(rid, '_', ' ')])
xlabel('wavenumber')
ylabel('phase diff')
grid on; zoom on

saveas(gcf, 'mean_phase_diff', 'fig')

