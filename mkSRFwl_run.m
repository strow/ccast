
% build SRF matrices

wlist = [773.1300, 773.1305]
sfile = 'data/SRF_v33a_LW.mat';
mkSRFwl('LW', wlist, sfile)

sfile = 'data/SRF_v33a_MW.mat';
mkSRFwl('MW', wlist, sfile)

sfile = 'data/SRF_v33a_SW.mat';
mkSRFwl('SW', wlist, sfile)

