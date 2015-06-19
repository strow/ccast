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

[foax, frad] = fp_v33a('LW');
opts.foax = foax; opts.frad = frad;
sfile = 'SAinv_LR_Pn_ag_LW.mat';
mkSAinv('LW', wlaser, sfile, opts);

[foax, frad] = fp_v33a('MW');
opts.foax = foax; opts.frad = frad;
sfile = 'SAinv_LR_Pn_ag_MW.mat';
mkSAinv('MW', wlaser, sfile, opts);

[foax, frad] = fp_v33a('SW');
opts.foax = foax; opts.frad = frad;
sfile = 'SAinv_LR_Pn_ag_SW.mat';
mkSAinv('SW', wlaser, sfile, opts);

