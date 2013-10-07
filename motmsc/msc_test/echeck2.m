%
% quick look at changes in LW eng packet emissivity
%

f1 = '/asl/data/cris/ccast/daily/2013/allsci20130827.mat';

load(f1);

opt1.resmode = 'hires2';
[inst, user] = inst_params('LW', 773.1301, opt1);

n = length(alleng);

eall = zeros(inst.npts, n);

for i = 1 : n
  eall(:, i)  = alleng(i).ICT_Param.Band(1).ICT.EffEmissivity.Pts;
end

figure(1); clf
plot(inst.freq, eall)
grid on; zoom on

figure(2); clf
plot(inst.freq(2:end), diff(eall));
grid on; zoom on

