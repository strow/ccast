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
ghome = '/asl/data/cris/sdr60';
rhome = '/asl/data/cris/rdr60';

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
opts.gitID = 'c0a1bce';
opts.btrim = 'btrim_cache.mat';
opts.ctmp = ctmp;

% build file lists
dstr = sprintf('%03d', doy);
ystr = sprintf('%d', year);

% L1a output home
Lhome = '/asl/data/cris/ccast';
Ldir = sprintf('L1a_%s_s%02d', opts.cvers, nscanSC);
Lfull = fullfile(Lhome, Ldir, ystr, dstr);

% RDR file list
rdir = fullfile(rhome, ystr, dstr);
rlist = dir2list(rdir, 'RCRIS', nscanRDR);
  rlist = rlist(41:50);  % TEST TEST TEST

% Geo file list
gdir = fullfile(ghome, ystr, dstr);
glist = dir2list(gdir, 'GCRSO', nscanGeo);
  glist = glist(41:50);  % TEST TEST TEST

% create the output path, if needed
unix(['mkdir -p ', Ldir]);

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

