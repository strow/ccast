%
% call rdr2sdr on regular data
%

% set bcast paths
addpath /home/motteler/cris/bcast
addpath /home/motteler/cris/bcast/davet

% select day-of-the-year
doy = '128';

% set RDR and SDR base paths
RDR_mat = '/asl/data/cris/rdr60/mat/2012/';
SDR_mat = '/home/motteler/cris/data/2012/';
RDR_HDF = '/asl/data/cris/rdr60/hdf/2012/';
SDR_HDF = '/asl/data/cris/sdr60/hdf/2012/';

% set path for allgeo
daily_mat = '/home/motteler/cris/data/2012/daily';  

% get geo filename allgeo<yyyymmdd>.mat from day-of-year
tmp = datestr(datenum(2012,1,1) + str2num(doy) - 1, 30);
geofile = fullfile(daily_mat, ['allgeo', tmp(1:8), '.mat']);

% full path to matlab RDR files
rdir = fullfile(RDR_mat, doy);

% full path to matlab SDR files
sdir = fullfile(SDR_mat, doy);

% get matlab RDR file list
flist = dir(fullfile(rdir, 'RDR*.mat'));
% flist = flist(61:64);
% flist = flist(2:(end-1));
flist = flist(26:end);

% initialize opts
opts = struct;
opts.geofile = geofile;  % geo filename for this day

% misc params
opts.avgdir = '.';   % moving avg working directory
opts.mvspan = 4;     % moving avg span is 2*mvspan + 1

% instrument files
opts.sfileLW = 'inst_data/SRF_v33a_LW.mat';  % LW SRF table
opts.sfileMW = 'inst_data/SRF_v33a_MW.mat';  % MW SRF table
opts.sfileSW = 'inst_data/SRF_v33a_SW.mat';  % SW SRF table

opts.DClevel_file = 'inst_data/DClevel_parameters_22July2008.mat';
opts.cris_NF_file = 'inst_data/cris_NF_dct_20080617modified.mat';

% profile clear
% profile on

[slist, msc] = rdr2sdr(flist, rdir, sdir, opts);

% profile viewer

