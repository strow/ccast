%
% NAME
%   bcast_main -- wrapper to process matlab RDR to SDR data
%
% SYNOPSIS
%   bcast_main(doy)
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
%   bcast_main is the last of several processing steps, and needs
%   matlab RDR files and geo daily summary data.
%
%   The paths to data are set up as ../yyyy/doy/ but that's just a
%   convention, doy can be any subset of the day's data.  The only
%   restriction is that the current setup uses doy to match the geo
%   daily summary, so doy can't be subset that spans days.
%
%   To switch to one of the high res mode, addpath ../motmsc/hires,
%   set opt.resmode to 'hires1' or 'hires2', and set opts.XW.sfile 
%   to a high res SRF tabulation.
%

function bcast_main(doy, year)

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

% search source, then davet
addpath ../davet
addpath ../source

% for high-res ONLY
% addpath ../motmsc/hires

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
opts.avgdir = '.';        % moving avg working directory
opts.mvspan = 4;          % moving avg span is 2*mvspan + 1

% instrument SRF files
opts.LW.sfile = '../inst_data/SRF_v33a_LW.mat';  % LW SRF table
opts.MW.sfile = '../inst_data/SRF_v33a_MW.mat';  % MW SRF table
opts.SW.sfile = '../inst_data/SRF_v33a_SW.mat';  % SW SRF table

% high-res SRF files
% opts.LW.sfile = '../inst_data/SRF_vxHR_LW.mat';  % LW SRF table
% opts.MW.sfile = '../inst_data/SRF_vxHR_MW.mat';  % MW SRF table
% opts.SW.sfile = '../inst_data/SRF_vxHR_SW.mat';  % SW SRF table

% nonlinearity correction
opts.DClevel_file = '../inst_data/DClevel_parameters_22July2008.mat';
opts.cris_NF_file = '../inst_data/cris_NF_dct_20080617modified.mat';

% ICT modeling
opts.eFlag = 1;      % set to 1 to read emissivity from eng packet
opts.LW.eICT = NaN;  % no LW eICT value read when eFlag is 1
opts.MW.eICT = NaN;  % no MW eICT value read when eFlag is 1
opts.SW.eICT = NaN;  % no SW eICT value read when eFlag is 1

%--------------------------------
% process matlab RDR to SDR data 
%--------------------------------

% profile clear
% profile on

[slist, msc] = rdr2sdr(flist, rdir, sdir, opts);

% profile viewer

