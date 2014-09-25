%
% mkSRFrun -- call mkSRFtab with typical values
%

more off

% inst_params options
opt1 = struct;
opt1.resmode = 'lowres';

% newILS options
opt2 = struct;
opt2.wrap = 'psinc n';

wlist = [773.1300, 773.1305];

sfile = 'SRF_v33aLR_LW.mat';
mkSRFtab('LW', wlist, sfile, opt1, opt2)

sfile = 'SRF_v33aLR_MW.mat';
mkSRFtab('MW', wlist, sfile, opt1, opt2)

sfile = 'SRF_v33aLR_SW.mat';
mkSRFtab('SW', wlist, sfile, opt1, opt2)

