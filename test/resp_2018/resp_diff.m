
addpath ../motmsc/utils
addpath /home/motteler/shome/airs_decon/source

d1 = load('resp_30');
d2 = load('resp_36');
% d1 = load('fir_30');
% d2 = load('fir_36');

cvers = d1.opts.cvers;
band = d1.inst.band;
freq = d1.inst.freq;

figure(1); clf
set(gcf, 'DefaultAxesColorOrder', fovcolors);
subplot(2,1,1)
plot(freq, abs(d1.rcor))
axis([2100, 2600, 0, 1.1])
title([cvers, ' ', band, ' doy 30 optical responsivity'])
legend(fovnames, 'location', 'south')
xlabel('wavenumber')
ylabel('weight')
grid on

subplot(2,1,2)
plot(freq, abs(d2.rcor))
axis([2100, 2600, 0, 1.1])
title([cvers, ' ', band, ' doy 36 optical responsivity'])
legend(fovnames, 'location', 'south')
xlabel('wavenumber')
ylabel('weight')
grid on
saveas(gcf, 'doy_30_36_SW_resp', 'png')

y1 = hamm_app(abs(d1.rcor));
y2 = hamm_app(abs(d2.rcor));

figure(2); clf
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(freq, y2 - y1, 'linewidth', 2)
axis([2100, 2600, -0.04, 0.06])
title([cvers, ' ', band, ' doy 36 minus doy 30 optical responsivity'])
legend(fovnames, 'location', 'north')
xlabel('wavenumber')
ylabel('weight')
grid on
saveas(gcf, 'dif_30_36_SW_resp', 'png')

