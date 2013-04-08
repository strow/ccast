%
% call rdr2sdr on regular or high-res data
%
% demo wrapper that sets parameters for processing matlab RDR to SDR
% data.  edit paths and options as needed.  note that doy is set in
% an assignment here but can be replaced with a function definition.
%

% function bcast_main(doy)

% select day-of-the-year
doy = '071';

% set bcast paths
addpath ../davet
addpath ../source

% for high-res ONLY
addpath ../hires

% set RDR and SDR base paths
RDR_mat = '/asl/data/cris/rdr60/mat/2013/';
SDR_mat = '/home/motteler/cris/data/2013/';

% set path for allgeo
dailydir = '/home/motteler/cris/data/2013/daily';  

% get geo filename allgeo<yyyymmdd>.mat from day-of-year
tmp = datestr(datenum(2013,1,1) + str2num(doy) - 1, 30);
geofile = fullfile(dailydir, ['allgeo', tmp(1:8), '.mat']);

% full path to matlab RDR files
rdir = fullfile(RDR_mat, doy);

% full path to matlab SDR files
sdir = fullfile(SDR_mat, doy);

% create the matlab SDR directory, if necessary
unix(['mkdir -p ', sdir]);

% get matlab RDR file list
flist = dir(fullfile(rdir, 'RDR*.mat'));
% flist = flist(1:240);  % 23 feb high res, 16 may mat files
flist = flist(end-60:end);

% initialize opts
opts = struct;
opts.geofile = geofile;  % geo filename for this doy

% misc params
opts.avgdir = '.';   % moving avg working directory
opts.mvspan = 4;     % moving avg span is 2*mvspan + 1

% instrument SRF files
% opts.LW.sfile = 'inst_data/SRF_v33a_LW.mat';  % LW SRF table
% opts.MW.sfile = 'inst_data/SRF_v33a_MW.mat';  % MW SRF table
% opts.SW.sfile = 'inst_data/SRF_v33a_SW.mat';  % SW SRF table

% high-res SRF files
opts.LW.sfile = '../inst_data/SRF_v33aHR_LW.mat';  % LW SRF table
opts.MW.sfile = '../inst_data/SRF_v33aHR_MW.mat';  % MW SRF table
opts.SW.sfile = '../inst_data/SRF_v33aHR_SW.mat';  % SW SRF table

% nonlinearity correction
opts.DClevel_file = '../inst_data/DClevel_parameters_22July2008.mat';
opts.cris_NF_file = '../inst_data/cris_NF_dct_20080617modified.mat';

% ICT modeling
% opts.eFlag = 1;      % set to 1 to read emissivity from eng packet
% opts.LW.eICT = NaN;  % no LW eICT value read when eFlag is 1
% opts.MW.eICT = NaN;  % no MW eICT value read when eFlag is 1
% opts.SW.eICT = NaN;  % no SW eICT value read when eFlag is 1

% high res ICT modeling
dd = load('../inst_data/emissHR.mat');
opts.eFlag = 0;   % set to 0 to pass emissivity as a parameter
opts.LW.eICT = dd.e1hi;  % LW hi res emissivity
opts.MW.eICT = dd.e2hi;  % MW hi res emissivity
opts.SW.eICT = dd.e3hi;  % SW hi res emissivity

% process matlab RDR to SDR data 

% profile clear
% profile on

[slist, msc] = rdr2sdr(flist, rdir, sdir, opts);

% profile viewer

