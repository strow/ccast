%
% NAME
%   ccast_main -- wrapper to process matlab RDR to SDR data
%
% SYNOPSIS
%   ccast_main(doy, year)
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
%   ccast_main is the last of several processing steps, and uses
%   matlab RDR files and geo daily summary data from scripts such 
%   as rdr2mat.m and geo_daily.m
%
%   The paths to data are set up as ../yyyy/doy/ but that's just a
%   convention, doy can be any subset of the day's data.  The only
%   restriction is that the current setup uses doy to match the geo
%   daily summary, so doy can't be subset that spans days.
%
%   To switch to one of the high res modes, set opt.resmode to
%   'hires1' or 'hires2' and opts.LW_sfile, MW_sfile, and SW_sfile
%   to the high res SRF files.
%

function ccast_main(doy, year)

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
opts.resmode = 'lowres';  % mode for inst_params
opts.geofile = geofile;   % geo filename for this doy
opts.mvspan = 4;          % moving avg span is 2*mvspan + 1

% instrument SRF files
opts.LW_sfile = '../inst_data/SRF_v33a_LR_Pn_LW.mat';  % LW SRF table
opts.MW_sfile = '../inst_data/SRF_v33a_LR_Pn_MW.mat';  % MW SRF table
opts.SW_sfile = '../inst_data/SRF_v33a_LR_Pn_SW.mat';  % SW SRF table

% time-domain FIR filter 
opts.specNF_file = '../inst_data/FIR_19_Mar_2012.txt';

% NEdN principal component filter
opts.nedn_filt = '../inst_data/nedn_filt_LR.mat';

%--------------------------------
% process matlab RDR to SDR data 
%--------------------------------

% profile clear
% profile on

rdr2sdr(flist, rdir, sdir, opts);

% profile viewer

