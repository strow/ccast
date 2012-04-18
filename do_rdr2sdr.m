%
% call rdr2sdr on regular data
%

% RDR mat files
rdir = '/asl/data/cris/rdr60/mat/2012/056';

% RDR file list
flist = dir(sprintf('%s/RDR*.mat', rdir));
flist = flist(61:64);

% SDR mat files
sdir = '.';      

% optional params
opts = struct;
opts.avgdir = '.';   % moving avg working directory
opts.mvspan = 4;     % moving avg span is 2*mvspan + 1
opts.sfileLW = 'data/SRF_v33a_LW.mat';  % LW SRF table
opts.sfileMW = 'data/SRF_v33a_MW.mat';  % MW SRF table
opts.sfileSW = 'data/SRF_v33a_SW.mat';  % SW SRF table

% profile clear
% profile on

[slist, msc] = rdr2sdr(flist, rdir, sdir, opts);

% profile viewer

