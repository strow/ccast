%
% nedn_test3 -- compare two ccast NEdN runs
%

addpath ./utils
addpath ../source
addpath ../../airs_decon/source

%-----------------
% test parameters
%-----------------
band = 'SW';
res = 'hires2';  % lowres, hires1, hires2

% specify a ccast SDR file
s1 = 'SDR_d20150215_t0134364.mat';
p1 = '/asl/data/cris/ccast/sdr60_hr_t3/2015/046';
p2 = '/asl/data/cris/ccast/sdr60_hr_t4/2015/046';
f1 = fullfile(p1, s1);
f2 = fullfile(p2, s1);
dstr = '2015-01-15';

% get the data
d1 = load(f1);
d2 = load(f2);
switch(band)
  case 'LW', r1 = d1.nLW; r2 = d2.nLW; frq = d1.vLW;
  case 'MW', r1 = d1.nMW; r2 = d2.nMW; frq = d1.vMW;
  case 'SW', r1 = d1.nSW; r2 = d2.nSW; frq = d1.vSW;
end

%-------------------
% NEdN sample plots
%-------------------

figure(1); clf
plot(frq, r1(:, 1, 1), frq, r2(:, 1, 1))
title(sprintf('%s %s ccast NEdN comparison', dstr, band))
legend('old', 'new', 'location', 'northeast')
xlabel('wavenumber')
ylabel('d rad')
grid on; zoom on

%-----------------------
% compare radiance data
%-----------------------

[isequal(d1.rLW, d2.rLW), isequal(d1.rMW, d2.rMW), isequal(d1.rSW, d2.rSW)]

