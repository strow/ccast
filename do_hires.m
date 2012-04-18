%
% call rdr2sdr on the high-res data
%
% full res start 22 feb 2012 (doy 53) 22:15, 
% full res   end 23 feb 2012 (doy 54) 18:59, files 2-241

% RDR mat files
% rdir = '/asl/data/cris/rdr60/mat/2012/053'; 
rdir = '/asl/data/cris/rdr60/mat/2012/054';

% RDR file list
flist = dir(sprintf('%s/RDR*.mat', rdir));
flist = flist(121:124);

% SDR mat files
sdir = '.';      

% opts params
opts = struct;
opts.avgdir = '.';   % moving averages directory
opts.mvspan = 4;
opts.sfileLW = 'data/SRF_v33aHR_LW.mat';  % LW SRF table
opts.sfileMW = 'data/SRF_v33aHR_MW.mat';  % MW SRF table
opts.sfileSW = 'data/SRF_v33aHR_SW.mat';  % SW SRF table

% profile clear
% profile on

[slist, msc] = rdr2sdr(flist, rdir, sdir, opts);

% profile viewer

