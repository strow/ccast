%
% compare old and new numeric filters 
%

addpath ../source

% get the new time domain filter
band = 'SW';
wlaser = 773.1301;
opts = struct;
opts.resmode = 'hires2';
[inst, user] = inst_params(band, wlaser, opts);

specNF_file = '../inst_data/FIR_19_Mar_2012.txt';
fnew = specNF(inst, specNF_file);
vnew = inst.freq;

% get the old frequency domain filter
cris_NF_file = '../inst_data/cris_NF_dct_20080617modified.mat';
control.NF = load(cris_NF_file);
NF = control.NF.NF;
switch(band)
  case 'LW', fold = NF.lw; vold = NF.vlw;
  case 'MW', fold = NF.mw; vold = NF.vmw;
  case 'SW', fold = NF.sw; vold = NF.vsw;
end

% scale new to the old
w1 = max(fold) / max(fnew);

figure(1); clf
plot(vold, fold, vnew, w1 * fnew)

title(sprintf('%s old and new filters', band))
legend('old', 'new', 'location', 'south')
xlabel('wavenumber')
ylabel('filter weight')
grid on; zoom on


