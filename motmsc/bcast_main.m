%
% NAME
%   bcast_main -- wrapper to process matlab RDR to SDR data
%
% SYNOPSIS
%   bcast_main
%   bcast_main(doy)
%
% DISCUSSION
%   this is a wrapper script to set paths, files, and options to
%   process matlab RDR to matlab SDR files.  it can be modified to
%   work as a function with parameter doy (day of year as a 3-char
%   string).  the actual processing is done by rdr2sdr.
%
%   bcast_main is just one step in a chain of processing, it assumes
%   we have matlab RDR files and geo daily summary data available
%
%   the paths to data are set up as ../yyyy/doy/ but that's just a
%   convention, doy can be any subset of the day's data.  The only
%   restriction is that the current setup uses doy to match the geo
%   daily summary, so doy can't be subset that spans days.
%
%   matlab paths here are relative, they assume you are running one
%   level below the bcast installation home.  the search priority is
%   the current directory and then the reverse order the're set with
%   addpath.  So for example if you do
%
%     addpath ../davet
%     addpath ../source
% 
%   and then run in motmsc, files there will take precence, then
%   files from source, and finally files from davet
%

% function bcast_main(doy)

% select day-of-the-year
% doy = '054';  % high-res 2nd day
doy = '142';

% set bcast paths
addpath ../davet
addpath ../source

% for high-res ONLY
% addpath ../hires

% path to matlab RDR input by day-of-year
RDR_mat = '/asl/data/cris/rdr60/mat/2012/';

% path to matlab SDR output by day-of-year
SDR_mat = '/home/motteler/cris/data/2012/';  

% path to allgeo (and allsci) data
dailydir = '/home/motteler/cris/data/2012/daily';  

% get geo filename allgeo<yyyymmdd>.mat from day-of-year
tmp = datestr(datenum(2012,1,1) + str2num(doy) - 1, 30);
geofile = fullfile(dailydir, ['allgeo', tmp(1:8), '.mat']);

% full path to matlab RDR input files
rdir = fullfile(RDR_mat, doy);

% full path to matlab SDR output files
sdir = fullfile(SDR_mat, doy);

% create the matlab SDR directory, if necessary
unix(['mkdir -p ', sdir]);

% get matlab RDR file list
flist = dir(fullfile(rdir, 'RDR*.mat'));

% option to choose an RDR subset by index
% flist = flist(61:64);
% flist = flist((end-10):end);

% initialize opts
opts = struct;
opts.geofile = geofile;  % geo filename for this doy

% misc params
opts.avgdir = '.';   % moving avg working directory
opts.mvspan = 4;     % moving avg span is 2*mvspan + 1

% instrument SRF files
opts.LW.sfile = '../inst_data/SRF_v33a_LW.mat';  % LW SRF table
opts.MW.sfile = '../inst_data/SRF_v33a_MW.mat';  % MW SRF table
opts.SW.sfile = '../inst_data/SRF_v33a_SW.mat';  % SW SRF table

% high-res SRF files
% opts.LW.sfile = '../inst_data/SRF_v33aHR_LW.mat';  % LW SRF table
% opts.MW.sfile = '../inst_data/SRF_v33aHR_MW.mat';  % MW SRF table
% opts.SW.sfile = '../inst_data/SRF_v33aHR_SW.mat';  % SW SRF table

% nonlinearity correction
opts.DClevel_file = '../inst_data/DClevel_parameters_22July2008.mat';
opts.cris_NF_file = '../inst_data/cris_NF_dct_20080617modified.mat';

% ICT modeling
opts.eFlag = 1;      % set to 1 to read emissivity from eng packet
opts.LW.eICT = NaN;  % no LW eICT value read when eFlag is 1
opts.MW.eICT = NaN;  % no MW eICT value read when eFlag is 1
opts.SW.eICT = NaN;  % no SW eICT value read when eFlag is 1

% high res ICT modeling
% dd = load('inst_data/emissHR.mat');
% opts.eFlag = 0;   % set to 0 to pass emissivity as a parameter
% opts.LW.eICT = dd.e1hi;  % LW hi res emissivity
% opts.MW.eICT = dd.e2hi;  % MW hi res emissivity
% opts.SW.eICT = dd.e3hi;  % SW hi res emissivity

% process matlab RDR to SDR data 

% profile clear
% profile on

[slist, msc] = rdr2sdr(flist, rdir, sdir, opts);

% profile viewer

