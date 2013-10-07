%
% call rdr2dmp on high-res data
%

% select day-of-the-year
% doy = '053';  % high-res 1st day
doy = '054';  % high-res 2nd day

% set bcast paths
addpath ../davet
addpath ../source

% for high-res ONLY
addpath ../hires

% path to matlab RDR input by day-of-year
RDR_mat = '/asl/data/cris/rdr60/mat/2012/';

% path to matlab SDR output by day-of-year
SDR_mat = '/home/motteler/cris/data/2012/';  

% full path to matlab RDR input files
rdir = fullfile(RDR_mat, doy);

% full path to matlab SDR output files
sdir = fullfile(SDR_mat, doy);

% create the matlab SDR directory, if necessary
unix(['mkdir -p ', sdir]);

% get matlab RDR file list
flist = dir(fullfile(rdir, 'RDR*.mat'));

% option to choose an RDR subset by index
% flist = flist(end-26:end);  % for 22 feb high res
flist = flist(1:240);  % 23 feb high res, 16 may mat files

% initialize opts
opts = struct;

% process matlab RDR to SDR intermediate data
[slist, msc] = rdr2dmp(flist, rdir, sdir, opts);

