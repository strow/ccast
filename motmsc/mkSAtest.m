%
% mkSAtest -- test runs of mkSAinv
%

more off
addpath ../source

% inst_params options
opts = struct;
opts.resmode = 'hires2';

% newILS options
% opt2.wrap = 'sinc';
opts.wrap = 'psinc n';

% nominal wlaser value
wlaser = 773.1307;

% sfile = 'SRF_inv_HR2_Pn_LW.mat';
% mkSAinv('LW', wlaser, sfile, opts);

sfile = 'SRF_inv_HR2_Pn_MW.mat';
mkSAinv('MW', wlaser, sfile, opts);

sfile = 'SRF_inv_HR2_Pn_SW.mat';
mkSAinv('SW', wlaser, sfile, opts);

