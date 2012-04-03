
% build SRF matrices

wlist = [773.1300, 773.1305]
ffile = 'focalplane/fp_ccastLW.mat';
sfile = 'SRF_v1_LW.mat';
mkSRFwl('LW', wlist, ffile, sfile)

ffile = 'focalplane/fp_ccastMW.mat';
sfile = 'SRF_v1_MW.mat';
mkSRFwl('MW', wlist, ffile, sfile)

ffile = 'focalplane/fp_ccastSW.mat';
sfile = 'SRF_v1_SW.mat';
mkSRFwl('SW', wlist, ffile, sfile)

