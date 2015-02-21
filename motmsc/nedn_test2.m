%
% nedn_test2 -- quick look at ccast NEdN 
%

addpath ./utils
addpath ../source
addpath ../../airs_decon/source

%-----------------
% test parameters
%-----------------
band = 'LW';
res = 'hires2';  % lowres, hires1, hires2

% specify a ccast SDR file
cpath = '/asl/data/cris/ccast/sdr60_hr_tmp/2015/015/';
cfile = 'SDR_d20150115_t0314470.mat';
cboth = fullfile(cpath, cfile);
dstr = '2015-01-15';

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
ng = 2; % number of guard chans
n1 = round((user.v2 - user.v1) / user.dv) + 1;
vgrid = user.v1 - ng * user.dv + (0 : n1 + 2*ng -1) * user.dv;
nchan = length(vgrid);

%-------------------
% NEdN sample plots
%-------------------

fname = fovnames;
fcolor = fovcolors;

% rad subset for plots
rx = squeeze(r2(:, :, 2));

figure(3); clf
set(gcf, 'DefaultAxesColorOrder', fcolor);

plot(vgrid, rx)
axis([user.v1, user.v2, 0, ytop])
xlabel('wavenumber')
ylabel('d rad')
title(sprintf('%s %s sample ccast NEdN', dstr, band))
legend(fname, 'location', 'northeast')
grid on; zoom on

