%
% cal_test1 -- plot responsivity differences
%

addpath /asl/packages/airs_decon/source

% load convolved kcarta data
flat = load('cal_flat');
resp = load('cal_resp');

% get mean brightness temps
resp_btLW = mean(real(rad2bt(resp.frqLW, resp.radLW)), 2);
resp_btMW = mean(real(rad2bt(resp.frqMW, resp.radMW)), 2);
resp_btSW = mean(real(rad2bt(resp.frqSW, resp.radSW)), 2);

resp_sdLW = std(real(rad2bt(resp.frqLW, resp.radLW)), 0, 2);
resp_sdMW = std(real(rad2bt(resp.frqMW, resp.radMW)), 0, 2);
resp_sdSW = std(real(rad2bt(resp.frqSW, resp.radSW)), 0, 2);

flat_btLW = mean(real(rad2bt(flat.frqLW, flat.radLW)), 2);
flat_btMW = mean(real(rad2bt(flat.frqMW, flat.radMW)), 2);
flat_btSW = mean(real(rad2bt(flat.frqSW, flat.radSW)), 2);

flat_sdLW = std(real(rad2bt(flat.frqLW, flat.radLW)), 0, 2);
flat_sdMW = std(real(rad2bt(flat.frqMW, flat.radMW)), 0, 2);
flat_sdSW = std(real(rad2bt(flat.frqSW, flat.radSW)), 0, 2);

% concatenate bands
vobs = [flat.frqLW; flat.frqMW; flat.frqSW];
resp_bt = [resp_btLW; resp_btMW; resp_btSW];
resp_sd = [resp_sdLW; resp_sdMW; resp_sdSW];
flat_bt = [flat_btLW; flat_btMW; flat_btSW];
flat_sd = [flat_sdLW; flat_sdMW; flat_sdSW];

% load responsivity 
d1 = load('resp_filt');
resp_freq = [d1.freq_lw; d1.freq_mw; d1.freq_sw];
resp_filt = [d1.filt_lw; d1.filt_mw; d1.filt_sw];


% figure(1); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
% subplot(3,1,1)
% plot(resp_freq, resp_filt)
% axis([600, 2600, 0, 1.5])
% title('responsivity')
% ylabel('weight')
% grid on; zoom on

figure(1); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(2,1,1)
plot(vobs, resp_bt);
axis([600, 2600, 200, 300])
title('resp calc mean')
ylabel('dBT')
grid on; zoom on

subplot(2,1,2)
plot(vobs, resp_bt - flat_bt);
axis([600, 2600, -0.4, 0.4])
title('resp calc minus flat calc')
ylabel('dBT')
grid on; zoom on

  saveas(gcf, 'resp_mean_diff', 'png')
% export_fig('resp_mean_diff.pdf', '-m2', '-transparent')

figure(2); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(2,1,1)
plot(vobs, resp_sd);
axis([600, 2600, 0, 6])
title('resp calc std')
xlabel('wavenumber')
ylabel('dBT')
grid on; zoom on

subplot(2,1,2)
plot(vobs, resp_sd - flat_sd);
axis([600, 2600, -.06, 0.06])
title('resp std minus flat std')
xlabel('wavenumber')
ylabel('dBT')
grid on; zoom on

  saveas(gcf, 'resp_std_diff', 'png')
% export_fig('resp_std_diff.pdf', '-m2', '-transparent')

