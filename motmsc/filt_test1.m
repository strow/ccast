%
% filt_test1 -- compare ccast with old UW ATBD filters
%

band = 'LW';

addpath ../davet/zold
addpath ../source

% UMBC filter
wlaser = 773.1301;
[inst, user] = inst_params(band, wlaser);
umbc_lw = bandpass(inst.freq, ones(inst.npts,1), user.v1, user.v2, user.vr);

% Wisconsin filter
wisc_lw = ITTbandguards(lower(band));

% comparison plots
figure(1); clf
subplot(1,2,1)
plot(inst.freq, wisc_lw, inst.freq, umbc_lw)
ax(1) = user.v1 - user.vr - 5;
ax(2) = user.v1 + 5;
ax(3) = 0;  ax(4) = 1.1; axis(ax)
title(sprintf('ccast %s filter LHS', band))
legend('wisc', 'umbc', 'location', 'southeast')
xlabel('wavenumber')
ylabel('filter weight')
grid on; zoom on

subplot(1,2,2)
plot(inst.freq, wisc_lw, inst.freq, umbc_lw)
ax(1) = user.v2 - 5;
ax(2) = user.v2 + user.vr + 5;
ax(3) = 0;  ax(4) = 1.1; axis(ax)
title(sprintf('ccast %s filter RHS', band))
legend('wisc', 'umbc', 'location', 'southwest')
% xlabel('wavenumber')
% ylabel('filter weight')
grid on; zoom on

% saveas(gcf, ['ccast_filt_', band], 'png')

