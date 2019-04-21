%
% opts_L1a04_npp_H3 - wrapper to process NOAA RDR to ccast L1a files
%
% SYNOPSIS
%   opts_L1a04_npp_H3(year, doy)
%
% INPUTS
%   year  - integer year
%   doy   - integer day of year
%
% DISCUSSION
%   wrapper to set paths, files, and options to process NOAA RDR to
%   ccast L1a files.  It can be edited as needed to change options
%   and paths.  Processing is done by RDR_to_L1a.
%
%   this version is for 4-scan RDR and Geo data from GRAVITE
%

function ops_L1a04_npp_H3(year, doy)

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
ghome = '/asl/cris/gravite/gravite_npp/CrIS-SDR-GEO';
rhome = '/asl/cris/gravite/gravite_npp/CRIS-SCIENCE-RDR_SPACECRAFT-DIARY-RDR';

% get a CCSDS temp filename
ctmp = ccsds_tmpfile;

% RDR_to_L1a options struct
opts = struct;
opts.cvers = 'npp';
opts.cctag = '20a';
opts.ctmp = ctmp;

% load an initial eng packet 
load('../inst_data/npp_eng_v37_H3')
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
rlist = flist_wrap(rdir0, rdir1, 'RCRIS', nscanRDR);

% Geo file list
gdir0 = fullfile(ghome, ds0);
gdir1 = fullfile(ghome, ds1);
glist = flist_wrap(gdir0, gdir1, 'GCRSO', nscanGeo);

% L1a output home
Lhome = '/asl/cris/ccast';
Ldir = sprintf('L1a%02d_%s_H3', nscanSC, opts.cvers);
Lfull = fullfile(Lhome, Ldir, ys2, ds2);

% create the output path, if needed
if exist(Lfull) ~= 7, mkdir(Lfull), end

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

