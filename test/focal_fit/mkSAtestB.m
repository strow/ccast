%
% mkSAtestX - make SA test matrices
%

addpath ../source

% call get_fp for the focal plane
  name = 'umbc2';
% name = 'exelis';
band = {'LW', 'MW', 'SW'};
foax = NaN(9,3);
frad = NaN(9,3);
for i = 1 : 3
  fp = get_fp(band{i}, name);
  s = fp.s; d = fp.d;
  foax(:,i) = sqrt((s(:,2) + d(1)).^2 + (s(:,3) + d(2)).^2) ./ 1e6;
  frad(:,i) = ones(9,1) *  16808 / 2e6;
end

% inst_params options
opts = struct;
opts.version = 'j01';
opts.user_res = 'hires';
opts.inst_res = 'hires4';
opts.wrap = 'psinc n';

% nominal wlaser value
wlaser = 773.1307;

% get da and dv
d1 = load('testA_dv');
dv2daLW = d1.dapct(:) ./ d1.dvppmLW(:); dv2daLW(5) = 0; 
dv2daMW = d1.dapct(:) ./ d1.dvppmMW(:); dv2daMW(5) = 0; 
dv2daSW = d1.dapct(:) ./ d1.dvppmSW(:); dv2daSW(5) = 0;

% get Larrabee's frequency residuals (dv_obs)
dvLW = load('/home/strow/Work/Cris/Calval/J1/lw_ppm_neon.mat');
dvMW = load('/home/strow/Work/Cris/Calval/J1/mw_ppm_neon.mat');
dvSW = load('/home/strow/Work/Cris/Calval/J1/sw_ppm_neon.mat');

% apply (da/dv) * dv_obs
daLW = dv2daLW .* dvLW.ppm(:);
daMW = dv2daMW .* dvMW.ppm(:);
daSW = dv2daSW .* dvSW.ppm(:);

% build the SA inverse matrices
opts.frad = frad(:,1);
opts.foax = foax(:,1) .* (1 + daLW/100);
sfile = 'SAinv_testB_HR4_LW.mat';
mkSAinv('LW', wlaser, sfile, opts);

opts.frad = frad(:,2);
opts.foax = foax(:,2) .* (1 + daMW/100);
sfile = 'SAinv_testB_HR4_MW.mat';
mkSAinv('MW', wlaser, sfile, opts);

opts.frad = frad(:,3);
opts.foax = foax(:,3) .* (1 + daSW/100);
sfile = 'SAinv_testB_HR4_SW.mat';
mkSAinv('SW', wlaser, sfile, opts);

