%
% cal_test1 -- plot responsivity differences
%

addpath /asl/packages/airs_decon/source
addpath /asl/packages/ccast/source
addpath /home/motteler/matlab/export_fig

% load convolved kcarta data
flat = load('cal_flat');
resp = load('cal_resp');

% get mean brightness temps
resp_btLW = mean(real(rad2bt(resp.frqLW, resp.radLW)), 2);
resp_btMW = mean(real(rad2bt(resp.frqMW, resp.radMW)), 2);
resp_btSW = mean(real(rad2bt(resp.frqSW, resp.radSW)), 2);

resp_apLW = mean(real(rad2bt(resp.frqLW, hamm_app(resp.radLW))), 2);
resp_apMW = mean(real(rad2bt(resp.frqMW, hamm_app(resp.radMW))), 2);
resp_apSW = mean(real(rad2bt(resp.frqSW, hamm_app(resp.radSW))), 2);

flat_btLW = mean(real(rad2bt(flat.frqLW, flat.radLW)), 2);
flat_btMW = mean(real(rad2bt(flat.frqMW, flat.radMW)), 2);
flat_btSW = mean(real(rad2bt(flat.frqSW, flat.radSW)), 2);

flat_apLW = mean(real(rad2bt(flat.frqLW, hamm_app(flat.radLW))), 2);
flat_apMW = mean(real(rad2bt(flat.frqMW, hamm_app(flat.radMW))), 2);
flat_apSW = mean(real(rad2bt(flat.frqSW, hamm_app(flat.radSW))), 2);

% concatenate bands
vobs = [flat.frqLW; flat.frqMW; flat.frqSW];
resp_bt = [resp_btLW; resp_btMW; resp_btSW];
resp_ap = [resp_apLW; resp_apMW; resp_apSW];
flat_bt = [flat_btLW; flat_btMW; flat_btSW];
flat_ap = [flat_apLW; flat_apMW; flat_apSW];

% load responsivity 
d1 = load('resp_filt');
resp_freq = [d1.freq_lw; d1.freq_mw; d1.freq_sw];
resp_filt = [d1.filt_lw; d1.filt_mw; d1.filt_sw];

figure(1); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(3,1,1)
plot(resp_freq, resp_filt)
axis([600, 2600, 0, 1.5])
title('responsivity')
ylabel('weight')
grid on; zoom on

subplot(3,1,2)
plot(vobs, resp_bt - flat_bt);
axis([600, 2600, -0.4, 0.4])
title('resp calc minus flat calc')
ylabel('dBT')
grid on; zoom on

subplot(3,1,3)
plot(vobs, resp_ap - flat_ap);
axis([600, 2600, -.04, 0.04])
title('hamming resp calc minus hamming flat calc')
xlabel('wavenumber')
ylabel('dBT')
grid on; zoom on

% saveas(gcf, 'resp_flat_diff', 'png')
% export_fig('resp_flat_diff.pdf', '-m2', '-transparent')

