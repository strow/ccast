% 
% ils_test8 -- check newILS grid shifts
%

% select a FOV
iFOV = 5;

% inst_params options
band = 'SW';
wlaser =  773.1;
opt1 = struct;
opt1.resmode = 'hires2';
[inst1, user] = inst_params(band, wlaser, opt1);

v1 = inst1.freq(1);
v2 = inst1.freq(end);
dv = inst1.dv;

% build an extended grid
ng = 100;
nbase = round((v2 - v1) / dv) + 1;
vg1 = v1 - ng * dv + (0 : nbase + 2*ng -1) * dv;
vg1 = vg1(:);
npts = length(vg1);
inst1.freq = vg1;
inst1.npts = npts;

% shift vg1 to get vg2
vg2 = vg1 + dv * 0.1;
inst2 = inst1;
inst2.freq = vg2;

% choose an ILS center
k = floor(npts/3);
vc1 = vg1(k);
vc2 = vg2(k);

% newILS options
opt2 = struct;
opt2.wrap = 'sinc';

% call newILS on both grids
ils1 = newILS(iFOV, inst1, vc1, vg1, opt2);
ils2 = newILS(iFOV, inst2, vc2, vg2, opt2);

figure(1); clf
plot(vg1, ils1, vg2, ils2)
title('ILS 1 and ILS 2 at specified grids')
legend('ILS 1', 'ILS 2')
xlabel('wavenumber')
ylabel('weight')
grid on; zoom on

% compare function values
max(abs(ils1 - ils2))

figure(2); clf
plot(1:npts, ils1 - ils2)
title('ILS 1 minus ILS 2 function values')
xlabel('index')
ylabel('difference')
grid on; zoom on
