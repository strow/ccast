%
% resp_test2 - test kc2resp vectorization
%

addpath /home/motteler/matlab/export_fig
addpath /home/motteler/cris/ccast/source
addpath /home/motteler/cris/airs_decon/source
addpath /home/motteler/cris/ccast/motmsc/utils

% kcarta test data
kcdir = '/home/motteler/cris/sergio/JUNK2012/';
flist =  dir(fullfile(kcdir, 'convolved_kcart*.mat'));

% load kcarta file
d1 = load(fullfile(kcdir, flist(1).name));
vkc = d1.w(:); rkc = d1.r(:);

d1 = load(fullfile(kcdir, flist(2).name));
vkc = d1.w(:); rkc = [rkc, d1.r(:)];

d1 = load(fullfile(kcdir, flist(3).name));
vkc = d1.w(:); rkc = [rkc, d1.r(:)];

% get CrIS user struct
band = 'SW';
opt1 = struct;
opt1.resmode = 'hires2';
wlaser = 773.13;
[inst, user] = inst_params(band, wlaser, opt1);

% specify guard channels
ngc = 0;

% basic convolution
[rad1, frq1] = kc2cris(user, rkc, vkc, ngc);

% convolution with responsivity
[rad2, frq2] = kc2resp(user, rkc, vkc, ngc);

% convolve a single column
[rad3, frq3] = kc2resp(user, rkc(:, 2), vkc, ngc);

% compare
isequal(rad3, rad2(:, 2))

