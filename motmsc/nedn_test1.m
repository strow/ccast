%
% nedn_test1 -- quick look at NOAA NEdN 
%

addpath ./asl
addpath ./utils
addpath ../source

%-----------------
% test parameters
%-----------------
band = 'LW';
res = 'hires2';  % lowres, hires1, hires2

% specify a NOAA SDR file
spath = '/asl/data/cris/sdr4/hires/2015/045';
sfile = 'SCRIS_npp_d20150214_t1643299_e1643597_b17100_c20150215022155703629_star_f01.h5';
sboth = fullfile(spath, sfile);
dstr = '2015-02-13';

% get the data
pd = readsdr_rawpd(sboth);
switch(band)
  case 'LW', r1 = pd.ES_NEdNLW; ytop = 1.2;
  case 'MW', r1 = pd.ES_NEdNMW; ytop = 0.1;
  case 'SW', r1 = pd.ES_NEdNSW; ytop = 0.02;
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

figure(1); clf
set(gcf, 'DefaultAxesColorOrder', fcolor);
plot(vgrid, squeeze(r1(:, :, 15, 2)))
axis([user.v1, user.v2, 0, ytop])
xlabel('wavenumber')
ylabel('d rad')
title(sprintf('%s %s NOAA NEdN', dstr, band))
legend(fname, 'location', 'northeast')
grid on; zoom on
% saveas(gcf, sprintf('noaa_nedn_%s_all', band), 'fig')

figure(2); clf
plot(vgrid, squeeze(r1(:, 1, 15, :)))
axis([user.v1, user.v2, 0, ytop])
xlabel('wavenumber')
ylabel('d rad')
title(sprintf('%s %s NOAA FOV 1 FOR 15 NEdN', dstr, band))
legend('scan 1', 'scan 2', 'scan 3', 'scan 4', 'location', 'northeast')
grid on; zoom on
% saveas(gcf, sprintf('noaa_nedn_%s_fov1', band), 'fig')


