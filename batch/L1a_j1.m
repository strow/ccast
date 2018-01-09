%
% NAME
%   ccast_array -- run ccast on day-of-year from task ID
%
% SYNOPSIS
%   ccast_array(year)
%
% DISCUSSION
%  uses job array task ID (SLURM_ARRAY_TASK_ID) to get day-of-year
%

function ccast_array(year)

more off
addpath ../davet
addpath ../source
addpath ../test

procid = str2num(getenv('SLURM_PROCID'));
nprocs = str2num(getenv('SLURM_NPROCS'));
nodeid = sscanf(getenv('SLURMD_NODENAME'), 'n%d');
taskid = str2num(getenv('SLURM_ARRAY_TASK_ID'));

fprintf(1, 'L1a_npp: processing day %d, year %d, node %d\n', ...
            taskid, year, nodeid);

L1a_opts_j1(taskid, year)

