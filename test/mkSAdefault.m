%
% mkSAumbc - make umbc SA matrices
%

addpath ../source

% call get_fp for the focal planes 
name = 'default';
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

% build the SA inverse matrices
opts.frad = frad(:,1);
opts.foax = foax(:,1);
sfile = 'SAinv_default_HR4_LW.mat';
mkSAinv('LW', wlaser, sfile, opts);

opts.frad = frad(:,2);
opts.foax = foax(:,2);
sfile = 'SAinv_default_HR4_MW.mat';
mkSAinv('MW', wlaser, sfile, opts);

opts.frad = frad(:,3);
opts.foax = foax(:,3);
sfile = 'SAinv_default_HR4_SW.mat';
mkSAinv('SW', wlaser, sfile, opts);

