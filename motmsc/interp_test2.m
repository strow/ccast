% 
% interp_test2 - test complex vs regular versions of finterp
% 

addpath /home/motteler/cris/ccast/source
addpath /home/motteler/cris/airs_decon/test
addpath /home/motteler/cris/ccast/motmsc/utils

% kcarta test data
kcdir = '/home/motteler/cris/sergio/JUNK2012/';
flist =  dir(fullfile(kcdir, 'convolved_kcart*.mat'));

% choose a kcarta file
i = 10;
d1 = load(fullfile(kcdir, flist(i).name));
vkc = d1.w(:); rkc = d1.r(:);

% get CrIS inst and user params
band = 'LW';
opt1 = struct;
opt1.resmode = 'hires2';
wlaser = 773.1301;  % nominal value
[inst, user] = inst_params(band, wlaser, opt1);

% convolve kcarta to cris at the inst grid
[rad1, frq1] = kc2inst(inst, user, rkc, vkc);

% generate fake complex component
[m, n] = size(rad1);
rad2 = zeros(m,1);
rad2 = randn(m,1) .* rad1 + rad1;
% rad2(3:end,1) = rad1(1:end-2,1);

opt2 = struct;
opt2.tol = 1e-6;

% real component real interp
[rad1x, frq1x] = finterp(rad1, frq1, user.dv, opt2);

% imag component real interp
[rad2x, frq2x] = finterp(rad2, frq1, user.dv, opt2);

% complex input complex interp
[rad3x, frq3x] = finterp(rad1 + 1i * rad2, frq1, user.dv, opt2);

% compare
isclose(rad1x, real(rad3x), 4)
isclose(rad2x, imag(rad3x), 4)

% check inputs
% plot(frq1, rad1, frq1, rad2)
% legend('real', 'fake imag')
