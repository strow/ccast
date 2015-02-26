%
% nedn_test2 -- quick look at ccast NEdN 
%

addpath ./utils
addpath ../source
addpath ../../airs_decon/source

%-----------------
% test parameters
%-----------------
band = upper(input('band > ', 's'));
res = 'hires2';  % lowres, hires1, hires2

% specify a ccast SDR file
cpath = '/asl/data/cris/ccast/sdr60_hr_t1/2015/046';
% cfile = 'SDR_d20150215_t0214362.mat';
% cfile = 'SDR_d20150215_t0446353.mat';
% cfile = 'SDR_d20150215_t0614348.mat';
% cfile = 'SDR_d20150215_t0622348.mat';  % 0.086
% cfile = 'SDR_d20150215_t0630347.mat';  % 0.117
  cfile = 'SDR_d20150215_t0638347.mat';  % 0.120
% cfile = 'SDR_d20150215_t0646346.mat';

cboth = fullfile(cpath, cfile);
dstr = '2015-02-15';

% get the data
d1 = load(cboth);
switch(band)
  case 'LW', r2 = d1.nLW; ytop = 1.2;
  case 'MW', r2 = d1.nMW; ytop = 0.1;
  case 'SW', r2 = d1.nSW; ytop = 0.02;
end

% get user grid with guard bands
opts = struct;
opts.resmode = res;
[inst, user] = inst_params(band, 773.13, opts);
ugrid = cris_ugrid(user, 2);

%-------------------
% NEdN sample plots
%-------------------

fname = fovnames;
fcolor = fovcolors;

% rad subset for plots
rx = squeeze(r2(:, :, 2));

figure(3); clf
set(gcf, 'DefaultAxesColorOrder', fcolor);

plot(ugrid, rx)
axis([user.v1, user.v2, 0, ytop])
xlabel('wavenumber')
ylabel('d rad')
title(sprintf('%s %s sample ccast NEdN', dstr, band))
legend(fname, 'location', 'north')
grid on; zoom on

