%
% call rdr2sdr on regular data
%

% set bcast paths
addpath /home/motteler/cris/bcast
addpath /home/motteler/cris/bcast/davet

% RDR mat files
% rdir = '/asl/data/cris/rdr60/mat/2012/056';
rdir = '/asl/data/cris/rdr60/mat/2012/118';

% RDR file list
flist = dir(sprintf('%s/RDR*.mat', rdir));
% flist = flist(61:64);
flist = flist(81:84);
% flist = flist(65:68);

% SDR mat files
sdir = '.';      

% misc params
opts = struct;
opts.avgdir = '.';   % moving avg working directory
opts.mvspan = 4;     % moving avg span is 2*mvspan + 1

opts.sfileLW = 'data/SRF_v33a_LW.mat';  % LW SRF table
opts.sfileMW = 'data/SRF_v33a_MW.mat';  % MW SRF table
opts.sfileSW = 'data/SRF_v33a_SW.mat';  % SW SRF table

opts.DClevel_file = 'data/DClevel_parameters_22July2008.mat';
opts.cris_NF_file = 'data/cris_NF_dct_20080617modified.mat';

profile clear
profile on

[slist, msc] = rdr2sdr(flist, rdir, sdir, opts);

profile viewer

