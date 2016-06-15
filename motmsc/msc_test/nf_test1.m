%
% interpolate old filter to sensor grid
%

% old frequency-domain filter
load('../inst_data/cris_NF_dct_20080617modified.mat');
f1 = NF.sw; f1 = f1 ./ max(f1);
v1 = NF.vsw;

% instrument params
band = 'SW';
wlaser = 773.13;
opts = struct;
opts.resmode = 'lowres';
[inst, user] = inst_params(band, wlaser, opts);

% old filter interpolated to inst grid
[f2, v2] = finterp(f1, v1, inst.dv);
f2 = f2 ./ max(f2);

% new time-domain filter at inst grid
tfile = '../inst_data/FIR_19_Mar_2012.txt';
f3 = specNF(inst, tfile);
f3 = f3 ./ max(f3);
v3 = inst.freq;

figure(1); clf
plot(v1, f1, v2, f2, v3, f3)
title(sprintf('CrIS %s FIR filters', band))
legend('old freq domain', 'old interpolated', ...
       'new time domain', 'location', 'south')
xlabel('wavenumber')
ylabel('normalized weights')
grid on; zoom on


