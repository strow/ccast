%
% mkSRFrun -- call mkSRFtab with typical values
%

more off

opts = struct;
opts.resmode = 'lowres';
wlist = [773.1300, 773.1305];

sfile = 'SRF_v33aLR_LW.mat';
mkSRFtab('LW', wlist, sfile, opts)

sfile = 'SRF_v33aLR_MW.mat';
mkSRFtab('MW', wlist, sfile, opts)

sfile = 'SRF_v33aLR_SW.mat';
mkSRFtab('SW', wlist, sfile, opts)

