% 
% ils_test7 -- check newILS normalization
%

% select a FOV
iFOV = 1;

% inst_params options
band = 'SW';
wlaser =  773.1;
opt1 = struct;
opt1.resmode = 'hires2';
[inst, user] = inst_params(band, wlaser, opt1);

v1 = inst.freq(1);
v2 = inst.freq(end);
dv = inst.dv;

% build an extended grid
ng = 200;
nbase = round((v2 - v1) / dv) + 1;
vg1 = v1 - ng * dv + (0 : nbase + 2*ng -1) * dv;
vg1 = vg1(:);
npts = length(vg1);

% update the inst struct
inst.freq = vg1;
inst.npts = npts;

% take a subset of the extended grid
k = floor(npts/5);
vg2 = vg1(k : 3*k);

% choose an ILS center
v0 = vg1(floor(npts/3));

% newILS options
opt2 = struct;
opt2.wrap = 'sinc';

% call newILS on both grids
ils1 = newILS(iFOV, inst, v0, vg1, opt2);
ils2 = newILS(iFOV, inst, v0, vg2, opt2);

figure(1); clf
plot(vg1, ils1, 'r', vg2, ils2, 'b')
legend('ILS 1', 'ILS 2')
grid on; zoom on

% check normailzation
sum(ils1) - 1
sum(ils2) - 1

% compare over common subinterval
[ix, jx] = seq_match(vg1, vg2);
max(abs(ils1(ix) - ils2(jx)))

