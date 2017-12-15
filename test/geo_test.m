
%
% INPUTS
%   gdir  - NOAA GCRSO geo files
%   rdir  - NOAA RCRIS RDR files
%   sdir  - SDR output files
%   opts  - options struct

addpath ../source

gdir = '/asl/data/cris/sdr60/2017/091';
rdir = '/asl/data/cris/rdr60/2017/091';
sdir = './test_tmp';

opts = struct;
opts.mvspan = 4;

geo2sdr(gdir, rdir, sdir, opts)

