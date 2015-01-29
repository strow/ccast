%
% plot old and new numeric filters
%

addpath ../source
addpath /home/motteler/matlab/export_fig

% get instrument params
band = 'SW';
wlaser = 773.13;
opts = struct;
opts.resmode = 'hires2';
[inst, user] = inst_params(band, wlaser, opts);

% get the time-domain filter
tfile = '../inst_data/FIR_19_Mar_2012.txt';
sNF = specNF(inst, tfile);
inst.sNF = sNF;

% load 2008 UW numeric filters
uw_NF_file = '../inst_data/zold/cris_NF_dct_20080617modified.mat';
uw_NF = load(uw_NF_file);
uw_NF = uw_NF.NF;
switch upper(band)
  case 'LW'; uw_freq = uw_NF.vlw; uw_filt = uw_NF.lw; loc = 'south';
  case 'MW'; uw_freq = uw_NF.vmw; uw_filt = uw_NF.mw; loc = 'south';
  case 'SW'; uw_freq = uw_NF.vsw; uw_filt = uw_NF.sw; loc = 'east';
end

% plot filters
figure(1); clf
plot(inst.freq, sNF, uw_freq, uw_filt)
title(sprintf('%s numeric filters', band))
xlabel('wavenumber')
ylabel('weight')
legend('MIT 2012', 'UW 2008', 'location', loc)
grid on; zoom on
% export_fig(sprintf('filters_%s.pdf', band), '-m2', '-transparent')

