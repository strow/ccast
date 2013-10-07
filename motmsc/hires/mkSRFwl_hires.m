
% build SRF matrices

wlist = [773.1300, 773.1305]
sfile = 'SRF_vxHR_LW.mat';
mkSRFwl('LW', wlist, sfile)

sfile = 'SRF_vxHR_MW.mat';
mkSRFwl('MW', wlist, sfile)

sfile = 'SRF_vxHR_SW.mat';
mkSRFwl('SW', wlist, sfile)

