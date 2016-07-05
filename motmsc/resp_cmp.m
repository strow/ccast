%
% compare recent ccast with UW reference responsivity
%

% load responsivity 
d1 = load('resp_filt');
% resp_freq = [d1.freq_lw; d1.freq_mw; d1.freq_sw];
% resp_filt = [d1.filt_lw; d1.filt_mw; d1.filt_sw];

resp_freq = d1.freq_lw;
resp_filt = d1.filt_lw;

% load ccast obs
d2 = load('resp_obs');

vcc = d2.resp_freq;
rcc = d2.resp_obs;
ix = 650 <= vcc & vcc <= 1095;

rcc = rcc ./ (sum(rcc(ix)) / sum(ix));

figure(1)
plot(resp_freq, resp_filt, vcc, rcc)
axis([650, 1150, 0.7, 1.3])
title('CrIS responsivity measurements')
legend('UW ref', 'ccast obs', 'location', 'south')
grid on; zoom on

% addpath /home/motteler/matlab/export_fig
% export_fig('resp_cmp.pdf', '-m2', '-transparent')

