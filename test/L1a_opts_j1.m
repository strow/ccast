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
%   this version is for early tests with 4-scan RDR and Geo 
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
nscanRDR = 4;   % used for initial file selection
nscanGeo = 4;   % used for initial file selection
nscanSC = 45;   % used to define the SC granule format

% NOAA RDR and GCRSO homes 
ghome = '/asl/data/cris2/CrIS-SDR-GEO';
rhome = '/asl/data/cris2/CRIS-SCIENCE-RDR_SPACECRAFT-DIARY-RDR';

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
opts.cvers = 'j01';
opts.cctag = '20a';
opts.ctmp = ctmp;

% load an initial eng packet 
% *** this file should probably be in inst_data ***
load('j1_eng')
opts.eng = eng;

%------------------
% build file lists
%------------------

% "gravite" style date strings for inputs
[y0, d0] = prev_doy(year, doy);
v0 = datevec(datenum([y0, 1, d0]));
ds0 = sprintf('%02d%02d%02d', v0(1), v0(2), v0(3));
v1 = datevec(datenum([year, 1, doy]));
ds1 = sprintf('%02d%02d%02d', v1(1), v1(2), v1(3));

% year/doy style date strings for output
ys2 = sprintf('%d', year);
ds2 = sprintf('%03d', doy);

% RDR file list
rdir0 = fullfile(rhome, ds0);
rdir1 = fullfile(rhome, ds1);
rlist0 = dir2list(rdir0, 'RCRIS', nscanRDR);
rlist1 = dir2list(rdir1, 'RCRIS', nscanRDR);
rlist = [rlist0(end-2:end); rlist1];  % end-2 for 4-scan files
% rlist = rlist(820:end);  % TEST TEST TEST

% Geo file list
gdir0 = fullfile(ghome, ds0);
gdir1 = fullfile(ghome, ds1);
glist0 = dir2list(gdir0, 'GCRSO', nscanGeo);
glist1 = dir2list(gdir1, 'GCRSO', nscanGeo);
glist = [glist0(end-2:end); glist1];  % end-2 for 4-scan files
% glist = glist(820:end);  % TEST TEST TEST

% L1a output home
Lhome = '/asl/data/cris/ccast';
Ldir = sprintf('L1a_%s_s%02d', opts.cvers, nscanSC);
Lfull = fullfile(Lhome, Ldir, ys2, ds2);

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

