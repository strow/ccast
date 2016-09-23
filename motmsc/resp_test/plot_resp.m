%
% plot IASI and CrIS response functions
%

addpath /home/motteler/mot2008/fconv/respfnx
addpath /home/motteler/matlab/export_fig

v = 0 : 0.02 : 0.8;
x = 0 : 0.02 : 2;

% IASI apodization and response
figure(1); clf;
subplot(2,1,1)
plot(x, gaussapod(x, 2))
axis([0, 2, 0, 1.2])
title('IASI Gaussian apodization')
xlabel('displacement cm')
ylabel('weight')
grid on; zoom on

subplot(2,1,2)
plot(v, gaussresp(v, 2))
axis([0, 0.8, -0.2, 1.2])
title('IASI response function')
xlabel('wavenumber')
ylabel('weight')
grid on; zoom on

% saveas(gcf, 'iasi_apod_resp', 'png')
% export_fig('iasi_apod_resp.pdf', '-m2', '-transparent')

% IASI and CrIS response with tail zoom
figure(2); clf;
v2 = 0 : 0.04 : 1.4;
subplot(2,1,1)
plot(v2, gaussresp(v2, 2), v2, hamresp(v2, 0.8))
axis([0, 1.4 -0.2, 1.2])
title('IASI and CrIS response functions')
legend('IASI 2 cm Gaussian', 'CrIS 0.8 cm Hamming')
ylabel('weight')
grid on; zoom on

subplot(2,1,2)
v3 = 1 : 0.05 : 8;
plot(v3, gaussresp(v3, 2), v3, hamresp(v3, 0.8))
axis([1, 8, -0.01, 0.02])
title('response function tails')
legend('IASI 2 cm Gaussian', 'CrIS 0.8 cm Hamming')
xlabel('wavenumber')
ylabel('weight')
grid on; zoom on

% saveas(gcf, 'IASI_CrIS_resp', 'png')

