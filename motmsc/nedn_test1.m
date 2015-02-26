%
% nedn_test1 -- quick look at NOAA NEdN 
%

addpath ./asl
addpath ./utils
addpath ../source

%-----------------
% test parameters
%-----------------
band = upper(input('band > ', 's'));
res = 'hires2';  % lowres, hires1, hires2

% specify a NOAA SDR file
spath = '/asl/data/cris/sdr4/hires/2015/046';
% sfile = 'SCRIS_npp_d20150215_t0215139_e0215437_b17106_c20150215173025525829_star_f01.h5';
% sfile = 'SCRIS_npp_d20150215_t0448179_e0448477_b17107_c20150215180726084685_star_f01.h5';
% sfile = 'SCRIS_npp_d20150215_t0615459_e0616157_b17108_c20150215183704208414_star_f01.h5';
  sfile = 'SCRIS_npp_d20150215_t2006339_e2007037_b17116_c20150216040716829437_star_f01.h5';

sboth = fullfile(spath, sfile);
dstr = '2015-02-15';

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
legend(fname, 'location', 'north')
grid on; zoom on
% saveas(gcf, sprintf('noaa_nedn_%s_all', band), 'fig')

return

figure(2); clf
plot(vgrid, squeeze(r1(:, 1, 15, :)))
axis([user.v1, user.v2, 0, ytop])
xlabel('wavenumber')
ylabel('d rad')
title(sprintf('%s %s NOAA FOV 1 FOR 15 NEdN', dstr, band))
legend('scan 1', 'scan 2', 'scan 3', 'scan 4', 'location', 'northeast')
grid on; zoom on
% saveas(gcf, sprintf('noaa_nedn_%s_fov1', band), 'fig')

