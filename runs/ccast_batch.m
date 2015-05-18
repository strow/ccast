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

fprintf(1, 'ccast_batch: processing day %d, year %d\n', d1 + procid, year)

% ccast_main(d1 + procid, year)
ccast_c6_Pd_ag(d1 + procid, year)

