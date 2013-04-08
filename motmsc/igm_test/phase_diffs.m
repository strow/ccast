
d1 = load('d20120223_t0353302_FOR_15.mat');
d2 = load('d20120223_t0353302_FOR_16.mat');
d3 = load('d20120227_t0728566_FOR_15.mat');
d4 = load('d20120227_t0728566_FOR_16.mat');
d5 = load('d20120421_t0041415_FOR_15.mat');
d6 = load('d20120421_t0041415_FOR_16.mat');

dt_hi = d2.t2 - d1.t2;
dt_lo1 = d4.t2 - d3.t2;
dt_lo2 = d6.t2 - d5.t2;

figure(1); clf
subplot(2,1,1)
plot(d1.freq, dt_hi, d3.freq, dt_lo1)
title('high and regular res phase diffs')
xlabel('wavenumber')
ylabel('radians')
legend('hi res even - odd phase', ...
       'lo res even - odd phase', ...
       'location', 'southwest')
grid on; zoom on

subplot(2,1,2)
plot(d3.freq, dt_lo1, d5.freq, dt_lo2) 
title('old and new FIR phase diffs')
xlabel('wavenumber')
ylabel('radians')
legend('old FIR even - odd phase', ...
       'new FIR even - odd phase', ...
       'location', 'southeast')
grid on; zoom on
saveas(gcf, 'phase_diffs', 'png')

