%
% mkSArunX -- call mkSAinvX with typical values
%

more off
addpath ../source

% inst_params options
opts = struct;
opts.version = 'snpp';    % current active CrIS
opts.resmode = 'hires2';  % mode for inst_params
opts.addguard = 'true';   % include guard points 

% newILS options
% opts.wrap = 'psinc n';
% opts.wrap = 'sinc';
opts.wrap = 'psinc n*d';

% nominal wlaser value
wlaser = 773.1307;

sfile = 'SAinv_HR2_Pd_ag_LW.mat';
mkSAinvX('LW', wlaser, sfile, opts);

sfile = 'SAinv_HR2_Pd_ag_MW.mat';
mkSAinvX('MW', wlaser, sfile, opts);

sfile = 'SAinv_HR2_Pd_ag_SW.mat';
mkSAinvX('SW', wlaser, sfile, opts);

