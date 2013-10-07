%
% compare eng packet vs older saved emissivity
%

addpath utils

sdr = 'SDR_d20130827_t1823008.mat';

p1 = '/asl/data/cris/ccast/sdr60/2013/239/';        
p2 = '/asl/data/cris/ccast/sdr60_hr_test/2013/239/';

f1 = [p1, sdr];
f2 = [p2, sdr];

d1 = load(f1);
d2 = load(f2);

x1 = d1.vLW;
x2 = d2.vLW;

y1 = squeeze(pcorr2(d1.rLW(:, 5, 15, 30)));
y2 = squeeze(pcorr2(d2.rLW(:, 5, 15, 30)));

% figure(1); clf
% plot(x1, y1, x2, y2)
% legend('old', 'new')
% grid on; zoom on

figure(1); clf
plot(x1, (y2 - y1))
grid on; zoom on

x3 = d1.instLW.freq;
e_ICT = d1.eng.ICT_Param.Band(1).ICT.EffEmissivity.Pts;
dd = load('../inst_data/emisvxHR.mat')

figure(2); clf
plot(x3, e_ICT - dd.e1hi)
grid on; zoom on

