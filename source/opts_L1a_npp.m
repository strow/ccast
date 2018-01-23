%
% L1a_options -- wrapper to process RDR to L1a data
%
% SYNOPSIS
%   L1a_options(doy, year)
%
% INPUTS
%   day   - integer day of year
%   year  - integer year, default is 2013
%
% DISCUSSION
%   wrapper script to set paths, files, and options for RDR_to_L1a
%   to process NOAA RDR to ccast L1a files.  It can be edited as
%   needed to change options and paths.
%

function L1a_options(doy, year)

% search paths
addpath ../source
addpath ../davet
addpath ../motmsc/time
addpath ../readers/MITreader380b
addpath ../readers/MITreader380b/CrIS

%------------------------
% data paths and options
%------------------------

% scans per file
nscanRDR = 60;  % used for initial file selection
nscanGeo = 60;  % used for initial file selection
nscanSC = 45;   % used to define the SC granule format

% NOAA RDR and GCRSO homes
ghome = '/asl/data/cris/geo60_npp';
rhome = '/asl/data/cris/rdr60_npp';

% get a CCSDS temp filename
jdir = getenv('JOB_SCRATCH_DIR');
pstr = getenv('SLURM_PROCID');
if ~isempty(jdir) && ~isempty(pstr)
  ctmp = fullfile(jdir, sprintf('ccsds_%s.tmp', pstr));
else
  ctmp = sprintf('ccsds_%05d.tmp', randi(99999));
end

% RDR_to_L1a options struct
opts = struct;
opts.cvers = 'npp';
opts.cctag = '20a';
opts.ctmp = ctmp;

% load an initial eng packet 
load('../inst_data/npp_eng')
opts.eng = eng;

%------------------
% build file lists
%------------------

% get previous day
[y0, d0] = prev_doy(year, doy);
ys0 = sprintf('%d', y0);
ds0 = sprintf('%03d', d0);
ys1 = sprintf('%d', year);
ds1 = sprintf('%03d', doy);

% RDR file list
rdir0 = fullfile(rhome, ys0, ds0);
rdir1 = fullfile(rhome, ys1, ds1);
rlist0 = dir2list(rdir0, 'RCRIS', nscanRDR);
rlist1 = dir2list(rdir1, 'RCRIS', nscanRDR);
rlist = [rlist0(end); rlist1];
% rlist = rlist(41:50);  % TEST TEST TEST

% Geo file list
gdir0 = fullfile(ghome, ys0, ds0);
gdir1 = fullfile(ghome, ys1, ds1);
glist0 = dir2list(gdir0, 'GCRSO', nscanGeo);
glist1 = dir2list(gdir1, 'GCRSO', nscanGeo);
glist = [glist0(end); glist1];
% glist = glist(41:50);  % TEST TEST TEST

% L1a output home
Lhome = '/asl/data/cris/ccast';
Ldir = sprintf('L1a%02d_%s_H3', nscanSC, opts.cvers);
Lfull = fullfile(Lhome, Ldir, ys1, ds1);

% create the output path, if needed
unix(['mkdir -p ', Lfull]);

%-----------------------------------------
% take RDR and Geo to ccast L1b/SDR files
%-----------------------------------------

if isempty(rlist)
  fprintf(1, 'L1a_options: no RDR files found\n')
  return
end

if isempty(glist)
  fprintf(1, 'L1a_options: no Geo files found\n')
  return
end

RDR_to_L1a(rlist, glist, Lfull, opts)

