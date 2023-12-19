%
% cris_map_loop - global map from a day of SDR data
%

% set up source paths
addpath /home/motteler/cris/ccast/source
addpath /home/motteler/cris/ccast/motmsc/time
addpath /home/motteler/shome/obs_stats/obs_source
addpath /home/motteler/shome/obs_stats/source
addpath /home/motteler/shome/airs_tiling
addpath /asl/packages/airs_decon/source

% get latitude bands
dLat = 1;
latB = -90 : dLat : 90;    
nlat = length(latB) - 1;

% get longitude bands
dLon = 1;
lonB = -180 : dLon : 180;
nlon = length(lonB) - 1;

% set obs list parameters
opt1 = struct;
year = 2023;       % year
doy = 46;          % day-of-year
ofile = 'obs_xx';  % obs list temp file

% path to CrIS data
opt1.cdir = '/asl/cris/ccast_v1/sdr45_j02_HR';

% use Hamming apodization
opt1.hapod = 1;  

% set "c05", low strat, CO2, and window
opt1.vlist = [699.375, 746.875, 901.875, 902.500];
opt1.band = 'LW';

% build the obs list
cris_obs_list(year, doy, ofile, opt1)

d2 = load(ofile);
[nchan, nobs] = size(d2.rad_list);

% get the tile indices
[ilat, ilon, latB, lonB] = tile_index(dLat, dLon, d2.lat_list, d2.lon_list);

% initilaize the map
obs_map = NaN(nlat, nlon);

% save descending obs
for j = 1 : nobs
  if d2.asc_list(j) 
    obs_map(ilat(j), ilon(j)) = d2.rad_list(3, j);
  end
end

% % save all obs
% for j = 1 : nobs
%   obs_map(ilat(j), ilon(j)) = d2.rad_list(3, j);
% end

% do the map plot
fn = 1;
dstr = datestr(datenum(2023, 1, doy));
tstr = ['J2 902 cm-1 radiance, ', dstr, ' descending'];
fh = equal_area_map(fn, latB, lonB, obs_map, tstr);
% load llsmap5
% colormap(llsmap5)
% caxis([-0.4, 0.4])
c = colorbar;
c.Label.String = 'radiance';
saveas(gcf, sprintf('J2_902cm-1_doy_%d', doy), 'png')

