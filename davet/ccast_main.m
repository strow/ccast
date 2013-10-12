%
% NAME
%   ccast_main -- wrapper to process matlab RDR to SDR data
%
% SYNOPSIS
%   ccast_main(doy)
%
% INPUTS
%   day   - integer day of year
%   year  - integer year, default is 2013
%
% DISCUSSION
%   This is a wrapper script to set paths, files, and options to
%   process matlab RDR to SDR files.  It can be edited as needed     
%   to change options and paths.  The actual processing is done by
%   rdr2sdr.m
%
%   ccast_main is the last of several processing steps, and needs
%   matlab RDR files and geo daily summary data.
%
%   The paths to data are set up as ../yyyy/doy/ but that's just a
%   convention, doy can be any subset of the day's data.  The only
%   restriction is that the current setup uses doy to match the geo
%   daily summary, so doy can't be subset that spans days.
%
%   calmode 1        - rad cal before self-apod correction
%   calmode 2        - rad cal after self-apod correction
%   resample_mode 1  - resampling matrix
%   resample_mode 2  - FFT interpolation
%

function ccast_main(doy, year)

% set default year
if nargin == 1
  year = 2013;
end

% year and day-of-year as strings
ystr = sprintf('%d', year);
dstr = sprintf('%0.3d', doy);

%-------------------------
% set paths and get files 
%-------------------------

addpath ../source

% path to matlab RDR input files
rhome = '/asl/data/cris/ccast/rdr60/';
rdir = fullfile(rhome, ystr, dstr);
flist = dir(fullfile(rdir, 'RDR*.mat'));
% flist = flist(61:64);

% path to matlab SDR output files
shome = '/asl/data/cris/ccast/sdr60/';  
sdir = fullfile(shome, ystr, dstr);
unix(['mkdir -p ', sdir]);

% path to geo data, allgeo<yyyymmdd>.mat
ghome = '/asl/data/cris/ccast/daily/';
tmp = datestr(datenum(year,1,1) + doy - 1, 30);
geofile = fullfile(ghome, ystr, ['allgeo', tmp(1:8), '.mat']);

%----------------------------
% set opts struct parameters
%----------------------------

opts = struct;            % initialize opts
opts.calmode = 2;         %
opts.resample_mode = 1;   % 
opts.resmode = 'lowres';  % mode for inst_params
opts.geofile = geofile;   % geo filename for this doy
opts.avgdir = '.';        % moving avg working directory
opts.mvspan = 4;          % moving avg span is 2*mvspan + 1

% nonlinearity correction
opts.DClevel_file = '../inst_data/DClevel_parameters_22July2008.mat';
opts.cris_NF_file = '../inst_data/cris_NF_dct_20080617modified.mat';

% ICT modeling
opts.eFlag = 1;      % set to 1 to read emissivity from eng packet
opts.LW.eICT = NaN;  % no LW eICT value read when eFlag is 1
opts.MW.eICT = NaN;  % no MW eICT value read when eFlag is 1
opts.SW.eICT = NaN;  % no SW eICT value read when eFlag is 1

% calculate the ISA, as needed
wlaser = 773.1301;
isa_file = '../inst_data/ISA_7731301.mat';
if exist(isa_file)
  % load the current ISA file
  load(isa_file, 'isa');
else
  % calculate ISA and save the results
  fprintf(1, 'bcast_main: calculating ISA matrix\n')
  [utmp, sensor.lw] = spectral_params('LW', wlaser);
  [utmp, sensor.mw] = spectral_params('MW', wlaser);
  [utmp, sensor.sw] = spectral_params('SW', wlaser);
  isa = struct;
  for iFov = 1:9
    [isa.lw(iFov).isa] = computeISA(sensor.lw, iFov);
    [isa.mw(iFov).isa] = computeISA(sensor.mw, iFov);
    [isa.sw(iFov).isa] = computeISA(sensor.sw, iFov);
  end
  save(isa_file, 'isa');  
end

% for now, pass the ISA data in via the opts struct
opts.isa = isa;
clear isa

%--------------------------------
% process matlab RDR to SDR data 
%--------------------------------

% profile clear
% profile on

[slist, msc] = rdr2sdr(flist, rdir, sdir, opts);

% profile viewer

