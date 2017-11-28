
function geo_loop(doy, year)

% year and day-of-year as strings
ystr = sprintf('%d', year);
dstr = sprintf('%0.3d', doy);

%-------------------------
% set paths and get files 
%-------------------------

% search source, then davet
addpath ../davet
addpath ../source

% path to matlab RDR input files
rhome = '/asl/data/cris/ccast/rdr60_hr3';
rdir = fullfile(rhome, ystr, dstr);
flist = dir(fullfile(rdir, 'RDR*.mat'));
% flist = flist(91:96);

% path to matlab SDR output files
shome = '/asl/data/cris/ccast/sdr60_hr';
sdir = fullfile(shome, ystr, dstr);
unix(['mkdir -p ', sdir]);

% path to geo data, allgeo<yyyymmdd>.mat
ghome = '/asl/data/cris/ccast/daily';
tmp = datestr(datenum(year,1,1) + doy - 1, 30);
geofile = fullfile(ghome, ystr, ['allgeo', tmp(1:8), '.mat']);

