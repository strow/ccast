%
% mkSArun -- call mkSAinv with typical values
%

more off
addpath ../source

% inst_params options
opts = struct;
opts.cvers  = 'npp';
opts.user_res = 'hires';
opts.inst_res = 'hires3';
opts.wrap = 'psinc n';

% nominal wlaser value
wlaser = 773.1307;

[foax, frad] = fp_v33a('LW');
opts.foax = foax; opts.frad = frad;
sfile = 'SAinv_HR3_test_LW.mat';
mkSAinv('LW', wlaser, sfile, opts);

[foax, frad] = fp_v33a('MW');
opts.foax = foax; opts.frad = frad;
sfile = 'SAinv_HR3_test_MW.mat';
mkSAinv('MW', wlaser, sfile, opts);

[foax, frad] = fp_v33a('SW');
opts.foax = foax; opts.frad = frad;
sfile = 'SAinv_HR3_test_SW.mat';
mkSAinv('SW', wlaser, sfile, opts);

