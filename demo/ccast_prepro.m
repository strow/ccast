%
% NAME
%   ccast_prepro -- ccast preprocessing
%
% SYNOPSIS
%   ccast_prepro(d1, d2, year)
%
% INPUTS
%   d1     - integer start day-of-year
%   d2     - integer end day-of-year
%   year   - integer preprocessing year
%
% OUTPUTS
%   matlab RDR, allsci, and allgeo files
%
% DISCUSSION
%   ccast processing is typically is done in two passes.  Pass 1 is
%   done with this script, ccast_prepro, and pass 2 with ccast_main.
%   ccast_prepro loops on days of the year and calls three functions:
%   rdr2mat, sci_daily, and geo_daily.
%
%   rdr2mat reads NOAA RDR files (HDF5/CCSDS level 0 data) and
%   produces matlab RDR files, an intermediate or working level 0
%   format.
%
%   sci_daily reads the matlab RDR files and produces a daily
%   abstract of "science" (8-second) and "engineering" (4 minute)
%   support data, in files allsciYYYYMMDD.mat
%
%   geo_daily reads NOAA GCRSO HDF5 geo files and produces a daily
%   abstract of CrIS geo data, in files allgeoYYYYMMDD.mat
%
%   The second ccast pass takes matlab RDR and allgeo files and
%   produces calibrated radiances, which are saved as matlab SDR
%   files.  The allsci files are not used directly for this, and
%   are mainly for longer term instrument monitoring
%
%   ccast_prepro and ccast_main assume their data is organized by
%   year and day-of-the-year, but that is just a convention.  Paths
%   to data and the ccast installation should be changed as needed.
%
% AUTHOR
%  H. Motteler, 20 Feb 2012
%

function ccast_prepro(d1, d2, year)

more off

% set ccast paths
addpath ../davet
addpath ../source
addpath ../readers/MITreader380a

% set data paths
hdir = '../demo/rdr60_hdf';  % HDF RDR files
gdir = '../demo/sdr60_hdf';  % HDF GCRSO files
mdir = '../demo/rdr60_mat';  % matlab RDR files
odir = '../demo/daily_mat';  % matlab daily files

% add year to the path
hdir = fullfile(hdir, sprintf('%d', year));
gdir = fullfile(gdir, sprintf('%d', year));
mdir = fullfile(mdir, sprintf('%d', year));
odir = fullfile(odir, sprintf('%d', year));

% get a bit trim cache temp filename
jdir = getenv('JOB_SCRATCH_DIR');
pstr = getenv('SLURM_PROCID');
if ~isempty(jdir) && ~isempty(pstr)
  btrim = fullfile(jdir, sprintf('btrim_%s.mat', pstr));
else
  rng('shuffle');
  btrim = sprintf('btrim_%03d.mat', randi(999));
end

% loop on days of the year
for i = d1 : d2
  doy = sprintf('%03d', i);
  rdr2mat(doy, hdir, mdir, btrim);
  sci_daily(doy, mdir, odir); 
  geo_daily(doy, gdir, odir);
end

% clean up
delete(btrim)

