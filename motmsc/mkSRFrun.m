%
% mkSRFrun -- call mkSRFtab with typical values
%

more off
addpath ../source

% inst_params options
opt1 = struct;
opt1.resmode = 'hires2';

% newILS options
opt2 = struct;
% opt2.wrap = 'psinc n';
  opt2.wrap = 'sinc';

wlist = [773.1300, 773.1305];

sfile = 'SRF_v33a_HR2_S_LW.mat';
mkSRFtab('LW', wlist, sfile, opt1, opt2)

sfile = 'SRF_v33a_HR2_S_MW.mat';
mkSRFtab('MW', wlist, sfile, opt1, opt2)

sfile = 'SRF_v33a_HR2_S_SW.mat';
mkSRFtab('SW', wlist, sfile, opt1, opt2)

