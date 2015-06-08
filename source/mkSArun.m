%
% mkSArun -- call mkSAinv with typical values
%

more off
addpath ../source

% inst_params options
opts = struct;
opts.version = 'snpp';
opts.resmode = 'lowres';
opts.addguard = 'true';

% newILS options
opts.wrap = 'psinc n';

% nominal wlaser value
wlaser = 773.1307;

sfile = 'SAinv_LR_Pn_ag_LW.mat';
mkSAinv('LW', wlaser, sfile, opts);

sfile = 'SAinv_LR_Pn_ag_MW.mat';
mkSAinv('MW', wlaser, sfile, opts);

sfile = 'SAinv_LR_Pn_ag_SW.mat';
mkSAinv('SW', wlaser, sfile, opts);

