% 
% test 1 cold: d20160101_t1907172, t668 = 243, scan =  7, FOR = 15
% test 1 warm: d20160101_t0003237, t668 = 246, scan = 10, FOR = 15
% 
% test 2 cold: d20160103_t1315030, t668 = 242, scan = 11, FOR = 15
% test 2 warm: d20160103_t1307031, t668 = 245, scan = 18, FOR = 16
% 
% test 3 cold: d20160103_t0635053, t668 = 241, scan =  8, FOR = 16
% test 3 warm: d20160103_t0643052, t668 = 246, scan = 33, FOR = 16
% 

addpath ../source
addpath ../motmsc/utils
addpath /home/motteler/matlab/export_fig

c1 = load('nlc_cold_1');
w1 = load('nlc_warm_1');
c2 = load('nlc_cold_2');
w2 = load('nlc_warm_2');
c3 = load('nlc_cold_3');
w3 = load('nlc_warm_3');

% Vdc
Vdc1 = [c1.Vdc, w1.Vdc];
Vdc2 = [c2.Vdc, w2.Vdc];
Vdc3 = [c3.Vdc, w3.Vdc];

% DC level integral, Vlev = Vdc - Vinst
Vlev1 = [c1.Vdc - c1.Vinst, w1.Vdc - w1.Vinst];
Vlev2 = [c2.Vdc - c2.Vinst, w2.Vdc - w2.Vinst];
Vlev3 = [c3.Vdc - c3.Vinst, w3.Vdc - w3.Vinst];

% correction factor, corr = (1 + 2*a2*Vdc)
corr1 = [1 + 2*c1.a2.*c1.Vdc, 1 + 2*w1.a2.*w1.Vdc];
corr2 = [1 + 2*c2.a2.*c2.Vdc, 1 + 2*w2.a2.*w2.Vdc];
corr3 = [1 + 2*c3.a2.*c3.Vdc, 1 + 2*w3.a2.*w3.Vdc];

% compare warm and cold corrections
ix = [1:4, 6:9];
fprintf(1, 'correction ratio\n')
corr1(5,:) ./ mean(corr1(ix,:))
corr2(5,:) ./ mean(corr2(ix,:))
corr3(5,:) ./ mean(corr3(ix,:))

fprintf(1, 'DC level integral ratio\n')
Vlev1(5,:) ./ mean(Vlev1(ix,:))
Vlev2(5,:) ./ mean(Vlev2(ix,:))
Vlev3(5,:) ./ mean(Vlev3(ix,:))

% get associated spectra
sfile = '/asl/data/cris/ccast/sdr60/2016/001/SDR_d20160101_t1907172';
d1 = load(sfile); c1rad = d1.rLW(:, :, 15,  7);
sfile = '/asl/data/cris/ccast/sdr60/2016/001/SDR_d20160101_t0003237';
d1 = load(sfile); w1rad = d1.rLW(:, :, 15, 10);

sfile = '/asl/data/cris/ccast/sdr60/2016/003/SDR_d20160103_t1315030';
d1 = load(sfile); c2rad = d1.rLW(:, :, 15, 11);
sfile = '/asl/data/cris/ccast/sdr60/2016/003/SDR_d20160103_t1307031';
d1 = load(sfile); w2rad = d1.rLW(:, :, 16, 18);

sfile = '/asl/data/cris/ccast/sdr60/2016/003/SDR_d20160103_t0635053';
d1 = load(sfile); c3rad = d1.rLW(:, :, 16,  8);
sfile = '/asl/data/cris/ccast/sdr60/2016/003/SDR_d20160103_t0643052';
d1 = load(sfile); w3rad = d1.rLW(:, :, 16, 33);

vLW = d1.vLW;
c1bt = real(rad2bt(vLW, c1rad));
w1bt = real(rad2bt(vLW, w1rad));
c2bt = real(rad2bt(vLW, c2rad));
w2bt = real(rad2bt(vLW, w2rad));
c3bt = real(rad2bt(vLW, c3rad));
w3bt = real(rad2bt(vLW, w3rad));

figure(1); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(2,1,1)
plot(vLW, c1bt)
axis([650, 1100, 190, 250])
title('set 1, all FOVs, cold window')
ylabel('BT, K')
grid on; zoom on

subplot(2,1,2)
plot(vLW, w1bt)
axis([650, 1100, 200, 300])
title('set 1, all FOVs, warm window')
ylabel('BT, K')
xlabel('wavenumber, cm-1')
grid on; zoom on
% saveas(gcf, 'set1_all', 'png')
  export_fig('set1_all.pdf', '-m2', '-transparent')

figure(2); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(2,1,1)
plot(vLW, c2bt)
axis([650, 1100, 190, 250])
title('set 2, all FOVs, cold window')
ylabel('BT, K')
grid on; zoom on

subplot(2,1,2)
plot(vLW, w2bt)
axis([650, 1100, 200, 300])
title('set 2, all FOVs, warm window')
ylabel('BT, K')
xlabel('wavenumber, cm-1')
grid on; zoom on
% saveas(gcf, 'set2_all', 'png')
  export_fig('set2_all.pdf', '-m2', '-transparent')

figure(3); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(2,1,1)
plot(vLW, c3bt)
axis([650, 1100, 190, 250])
title('set 3, all FOVs, cold window')
ylabel('BT, K')
grid on; zoom on

subplot(2,1,2)
plot(vLW, w3bt)
axis([650, 1100, 200, 300])
title('set 3, all FOVs, warm window')
ylabel('BT, K')
xlabel('wavenumber, cm-1')
grid on; zoom on
% saveas(gcf, 'set3_all', 'png')
  export_fig('set3_all.pdf', '-m2', '-transparent')

figure(4); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(2,3,1)
plot(vLW, c1bt)
axis([667.5, 668.5, 242, 245])
title('set 1, cold window')
ylabel('BT, K')
grid on; zoom on

subplot(2,3,2)
plot(vLW, c2bt)
axis([667.5, 668.5, 240, 243])
title('set 2, cold window')
ylabel('BT, K')
grid on; zoom on

subplot(2,3,3)
plot(vLW, c3bt)
axis([667.5, 668.5, 239, 242])
title('set 3, cold window')
legend(fovnames, 'location', 'northwest')
ylabel('BT, K')
grid on; zoom on

subplot(2,3,4)
plot(vLW, w1bt)
axis([667.5, 668.5, 243, 246])
title('set 1, warm window')
ylabel('BT, K')
xlabel('cm-1')
grid on; zoom on

subplot(2,3,5)
plot(vLW, w2bt)
axis([667.5, 668.5, 243, 246])
title('set 2, warm window')
ylabel('BT, K')
xlabel('cm-1')
grid on; zoom on

subplot(2,3,6)
plot(vLW, w3bt)
axis([667.5, 668.5, 245, 248])
title('set 3, warm window')
legend(fovnames, 'location', 'northwest')
ylabel('BT, K')
xlabel('cm-1')
grid on; zoom on
% saveas(gcf, 'set3_all', 'png')
  export_fig('zoom_668.pdf', '-m2', '-transparent')

