
% build SRF matrices

wlist = [773.1300, 773.1305]
sfile = 'SRF_v2_LW.mat';
mkSRFwl('LW', wlist, sfile)

sfile = 'SRF_v2_MW.mat';
mkSRFwl('MW', wlist, sfile)

sfile = 'SRF_v2_SW.mat';
mkSRFwl('SW', wlist, sfile)

