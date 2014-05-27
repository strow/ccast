%
% wrapper for mkSRFwl, set parameters as needed
%

more off
addpath ../source
addpath ../motmsc/utils

opts = struct;
opts.resmode = 'hires2';
wlist = [773.1300, 773.1305]

sfile = 'SRF_v33aHR2_LW.mat';
mkSRFwl('LW', wlist, sfile, opts)

sfile = 'SRF_v33aHR2_MW.mat';
mkSRFwl('MW', wlist, sfile, opts)

sfile = 'SRF_v33aHR2_SW.mat';
mkSRFwl('SW', wlist, sfile, opts)

