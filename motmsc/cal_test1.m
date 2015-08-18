%
% cal_test1 -- plot responsivity double difference
%

% load convolved kcarta data
flat = load('cal_flatX');
resp = load('cal_respX');

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

figure(1); clf
subplot(3,1,1)
plot(vobs, resp_bt - flat_bt);
axis([600, 2600, -0.3, 0.3])
title('resp minus flat, 49 fitting profiles')
ylabel('dBT')
grid on; zoom on

subplot(3,1,2)
plot(vobs, resp_ap - flat_ap);
axis([600, 2600, -.02, 0.02])
title('ap resp minus ap flat, 49 fitting profiles')
ylabel('dBT')
grid on; zoom on

subplot(3,1,3)
plot(vobs, (resp_bt - flat_bt) - (resp_ap - flat_ap))
axis([600, 2600, -0.3, 0.3])
title('double difference')
xlabel('wavenumber')
ylabel('dBT')
grid on; zoom on

saveas(gcf, 'fit_prof_resp', 'png')
saveas(gcf, 'fit_prof_resp', 'fig')

