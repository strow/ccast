%
% mkSRFrun -- call mkSRFtab with typical values
%

more off
addpath ../source

% inst_params options
opt1 = struct;
opt1.resmode = 'hires1';

% newILS options
opt2 = struct;
opt2.wrap = 'psinc n';

wlist = [773.1300, 773.1305];

sfile = 'SRF_v33a_HR1_Pn_LW.mat';
mkSRFtab('LW', wlist, sfile, opt1, opt2)

sfile = 'SRF_v33a_HR1_Pn_MW.mat';
mkSRFtab('MW', wlist, sfile, opt1, opt2)

sfile = 'SRF_v33a_HR1_Pn_SW.mat';
mkSRFtab('SW', wlist, sfile, opt1, opt2)

