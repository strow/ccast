%
% NAME
%   ccast_batch -- run ccast on day-of-year from task ID
%
% SYNOPSIS
%   ccast_batch(year)
%
% INPUTS
%   year   - integer year
%
% OUTPUTS
%   matlab SDR files
%
% DISCUSSION
%  ccast_batch(d1, year) started with m tasks will process days 
%  d1, d1+1, d1+2, ..., d1+m-1
%

function ccast_batch(year)

more off

addpath ../davet
addpath ../source

procid = str2num(getenv('SLURM_PROCID'));
nprocs = str2num(getenv('SLURM_NPROCS'));
nodeid = sscanf(getenv('SLURMD_NODENAME'), 'n%d');
taskid = str2num(getenv('SLURM_ARRAY_TASK_ID'));

fprintf(1, 'ccast_batch: processing day %d, year %d, node %d\n', ...
            taskid, year, nodeid);

% ccast_lowres(taskid, year)
% ccast_hires2(taskid, year)
% ccast_hires3(taskid, year)
  ccast_h2tolow(taskid, year)
% ccast_h3tolow(taskid, year)

