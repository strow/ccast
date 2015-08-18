% 
% show_filts - show responsivity, numeric filter, and ccast bandpass 
% 

% paths to ccast
addpath /home/motteler/matlab/export_fig
addpath ../source
addpath ../motmsc/utils

% set CrIS sensor and user params
% band = 'LW';
band = input('band > ', 's');
opts = struct;
opts.resmode = 'hires2';
wlaser = 773.1307;  % SNPP recent value
[inst, user] = inst_params(band, wlaser, opts);

% time-domain FIR filter 
specNF_file = '../inst_data/FIR_19_Mar_2012.txt';

% get the spectral space numeric filter
sNF = specNF(inst, specNF_file);

% normalize numeric filter over the user grid
i1 = max(find(inst.freq <= user.v1));
i2 = min(find(user.v2 <= inst.freq));
sNF = sNF ./ mean(sNF(i1:i2));

% load responsivity data
d1 = load('resp_filt');

% band-specific filter setup
switch upper(band)
  case 'LW', resp_freq = d1.freq_lw; resp_filt = d1.filt_lw;
  case 'MW', resp_freq = d1.freq_mw; resp_filt = d1.filt_mw;
  case 'SW', resp_freq = d1.freq_sw; resp_filt = d1.filt_sw;
end
resp_npts = length(resp_freq);
resp_ones = ones(resp_npts, 1);

% ccast old bandpass
cc_old = bandpass(resp_freq, resp_ones, user.v1, user.v2, user.vr);

% ccast new bandpass
switch upper(band)
  case 'LW', pL =  650; pH = 1100; rL = 15; rH = 20; bi = 1;
  case 'MW', pL = 1200; pH = 1760; rL = 30; rH = 30; bi = 2;
  case 'SW', pL = 2145; pH = 2560; rL = 30; rH = 30; bi = 3;
end
[user.v1 - pL, pH - user.v2]
cc_new = bandpass(resp_freq, resp_ones, pL, pH, rL, rH);

% NOAS/ATBD processing filter
noaa1 = f_atbd(bi, 1 : inst.npts, 'noaa1');
noaa2 = f_atbd(bi, 1 : inst.npts, 'noaa2');

% plot responsivity, numeric filter, and ccast bandpass
switch upper(band)
  case 'LW', axL = [620, 660, 0, 1.2]; axR = [1090, 1130, 0, 1.2];
  case 'MW', axL = [1160, 1220, 0, 1.2]; axR = [1740, 1800, 0, 1.2];
  case 'SW', axL = [2100, 2160, 0, 1.2]; axR = [2540, 2600, 0, 1.2];
end
x1 = [inst.freq(1), inst.freq(end)]; 
x2 = [user.v1, user.v2];
y = [1, 1] * 0.8;

figure(1); clf
subplot(1,2,1)
plot(resp_freq, resp_filt, inst.freq, sNF, ...
     resp_freq, cc_old, resp_freq, cc_new, ...
     inst.freq, noaa1, inst.freq, noaa2, x2, y, '+')
axis(axL)
title([band ' CrIS Filters'])
legend('responsivity', 'numeric filter', ...
       'ccast old', 'ccast new', 'noaa old', 'noaa new', ...
       'user grid', 'location', 'northwest');
xlabel('wavenumber'); ylabel('normalized weight')
grid on; zoom on

subplot(1,2,2)
plot(resp_freq, resp_filt, inst.freq, sNF, ...
     resp_freq, cc_old, resp_freq, cc_new, ...
     inst.freq, noaa1, inst.freq, noaa2, x2, y, '+')
axis(axR)
title([band ' CrIS Filters'])
legend('responsivity', 'numeric filter', ...
       'ccast old', 'ccast new', 'noaa old', 'noaa new', ...
       'user grid', 'location', 'northeast');
xlabel('wavenumber'); ylabel('normalized weight')
grid on; zoom on

  saveas(gcf, sprintf('show_filts_%s', band), 'fig')
  export_fig( sprintf('show_filts_%s.pdf', band), '-m2', '-transparent')

