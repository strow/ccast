%
% NAME
%   ccast_batch -- run ccast on day-of-year d1 + procid
%
% SYNOPSIS
%   ccast_batch(d1, year)
%
% INPUTS
%   d1     - integer start day-of-year
%   year   - integer year
%
% OUTPUTS
%   matlab SDR files
%
% DISCUSSION
%  ccast_batch(d1, year) started with m tasks will process days 
%  d1, d1+1, d1+2, ..., d1+m-1
%

function ccast_batch(d1, year)

more off

addpath ../davet
addpath ../source

procid = str2num(getenv('SLURM_PROCID'));
nprocs = str2num(getenv('SLURM_NPROCS'));
nodeid = sscanf(getenv('SLURMD_NODENAME'), 'n%d');

fprintf(1, 'ccast_batch: processing day %d, year %d, node %d\n', ...
            d1 + procid, year, nodeid);

% ccast_lowres(d1 + procid, year)
% ccast_hires2(d1 + procid, year)
% ccast_hires3(d1 + procid, year)
% ccast_h2tolow(d1 + procid, year)
  ccast_h3tolow(d1 + procid, year)

