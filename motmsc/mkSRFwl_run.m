%
% wrapper for mkSRFwl, set parameters as needed
%

more off
addpath ../source
addpath ../motmsc/utils

opts = struct;
opts.resmode = 'hires2';
wlist = [773.1300, 773.1305]

sfile = 'SRF_v33aHR_LW_p.mat';
mkSRFwl('LW', wlist, sfile, opts)

sfile = 'SRF_v33aHR_MW_p.mat';
mkSRFwl('MW', wlist, sfile, opts)

sfile = 'SRF_v33aHR_SW_p.mat';
mkSRFwl('SW', wlist, sfile, opts)

