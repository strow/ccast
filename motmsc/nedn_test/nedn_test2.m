%
% nedn_test2 -- quick look at ccast NEdN 
%

addpath ./utils
addpath ../source
addpath /asl/packages/airs_decon/source

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
% cfile = 'SDR_d20150215_t0638347.mat';  % 0.120
% cfile = 'SDR_d20150215_t0646346.mat';  % 0.102
% cfile = 'SDR_d20150215_t0654346.mat';  % 0.110
  cfile = 'SDR_d20150215_t2006301.mat';  % 0.090

% cpath = '/asl/data/cris/ccast/sdr60_hr_t1/2015/047';
% cfile = 'SDR_d20150216_t0142283.mat';
% cfile = 'SDR_d20150216_t0150282.mat';
% cfile = 'SDR_d20150216_t0158282.mat';
% cfile = 'SDR_d20150216_t0206281.mat';
% cfile = 'SDR_d20150216_t0214281.mat';

% cpath = '/asl/data/cris/ccast/sdr60_hr/2015/048';
% cfile = 'SDR_d20150217_t0214200.mat';
% cfile = 'SDR_d20150217_t0222199.mat';
% cfile = 'SDR_d20150217_t0230199.mat';

% cpath = '/asl/data/cris/ccast/sdr60/2014/300';
% cfile = 'SDR_d20141027_t1213320.mat';
% cfile = 'SDR_d20141027_t1221319.mat';

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

