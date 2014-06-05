%
% mkSRFrun -- call mkSRFtab with typical values
%

more off
addpath ../source
addpath ../motmsc/utils

opts = struct;
opts.resmode = 'hires1';
wlist = [773.1300, 773.1305];

sfile = 'SRF_v33aHR1_LW.mat';
mkSRFtab('LW', wlist, sfile, opts)

sfile = 'SRF_v33aHR1_MW.mat';
mkSRFtab('MW', wlist, sfile, opts)

sfile = 'SRF_v33aHR1_SW.mat';
mkSRFtab('SW', wlist, sfile, opts)

