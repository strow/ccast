%
%  call rdr2dmp on regular data
%

% select day-of-the-year
% doy = '112';  % full day of SDR data
% doy = '128';  % full day of SDR data
doy = '058';  % shortly after hi res days

% set bcast paths
addpath ../davet
addpath ../source

% for high-res ONLY
% addpath ../hires

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
% flist = flist(61:64);
% flist = flist((end-10):end);

% initialize opts
opts = struct;

% process matlab RDR to SDR intermediate data
[slist, msc] = rdr2dmp(flist, rdir, sdir, opts);

