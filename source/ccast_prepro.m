%
% NAME
%   ccast_prepro -- ccast preprocessing
%
% SYNOPSIS
%   ccast_prepro(d1, d2, year, inst_res)
%
% INPUTS
%   d1       - integer start day-of-year
%   d2       - integer end day-of-year
%   year     - integer preprocessing year
%   inst_res - 'lowres' (default), 'hires1-3'
%
% OUTPUTS
%   matlab RDR, allsci, and allgeo files
%
% DISCUSSION
%   processing is done in two passes, pass 1 with ccast_prepro and
%   pass 2 with ccast_main.  ccast_prepro sets paths, loops on days
%   of the year and calls three functions: rdr2mat, sci_daily, and
%   geo_daily.  
%
%   rdr2mat reads NOAA HDF 5 RDR files and writes matlab RDR files.
%   geo_daily reads NOAA GCRSO HDF 5 data and produces an abstract
%   of CrIS geo data, in files allgeoYYYYMMDD.mat  sci_daily reads
%   matlab RDR files and produces an abstract of science (8-second)
%   and engineering (4 minute) data, in files allsciYYYYMMDD.mat.
%
%   The second ccast pass takes matlab RDR and allgeo files and
%   produces calibrated radiances, which are saved as matlab SDR
%   files.  The allsci files are not used directly for this, they
%   are mainly for longer term instrument monitoring
%
%   inst_res sets an initial bit trim mask and path to the matlab
%   RDR data, but once an eng packet is seen rdr2mat uses the bit
%   trim mask from that, and will follow resolution changes.
%
%   ccast_prepro and ccast_main organize data by year and day of the
%   year, but rd2mat and rdr2sdr should work from whatever directory
%   and paths they are passed
%
% AUTHOR
%  H. Motteler, 20 Feb 2012
%

function ccast_prepro(d1, d2, year, inst_res)

more off

binit = '';         % default initial bit trim mask
rdir = 'rdr60';     % default matlab RDR directory

% inst_res sets RDR directory and initial bit trim mask
if nargin == 4
  switch inst_res
    case 'lowres', rdir = 'rdr60'; 
    case 'hires1', rdir = 'rdr60_hr1';
    case 'hires2', rdir = 'rdr60_hr2'; binit = '../inst_data/btrim_hires2.mat';
    case 'hires3', rdir = 'rdr60_hr3'; binit = '../inst_data/btrim_hires3.mat';
    otherwise, error(['bad inst_res value: ', inst_res]);
  end
end

% set ccast paths
addpath ../davet
addpath ../source
addpath ../readers/MITreader380a

% set data paths
hdir = '/asl/data/cris/rdr60/hdf';     % HDF RDR files
gdir = '/asl/data/cris/sdr60/hdf';     % HDF GCRSO files
mdir = '/asl/data/cris/ccast';         % matlab RDR files
ddir = '/asl/data/cris/ccast/daily';   % matlab daily files

% add year to the paths
hdir = fullfile(hdir, sprintf('%d', year));
gdir = fullfile(gdir, sprintf('%d', year));
mdir = fullfile(mdir, rdir, sprintf('%d', year));
ddir = fullfile(ddir, sprintf('%d', year));

% get a bit trim cache temp filename
jdir = getenv('JOB_SCRATCH_DIR');
pstr = getenv('SLURM_PROCID');
if ~isempty(jdir) && ~isempty(pstr)
  btrim = fullfile(jdir, sprintf('btrim_%s.mat', pstr));
else
  rng('shuffle');
  btrim = sprintf('btrim_%03d.mat', randi(999));
end

% use initial bit trim file, if available
if exist(binit) == 2
  [s, m] = copyfile(binit, btrim);
  if ~s, error(m), end
end

% loop on days of the year
for i = d1 : d2
  doy = sprintf('%03d', i);
  rdr2mat(doy, hdir, mdir, btrim);
  sci_daily(doy, mdir, ddir); 
  geo_daily(doy, gdir, ddir);
end

% clean up
delete(btrim)

