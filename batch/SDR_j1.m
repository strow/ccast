%
% NAME
%   SDR_j1 -- run ccast v20 on day-of-year from task ID
%
% SYNOPSIS
%   SDR_j1(year)
%
% DISCUSSION
%  uses job array task ID (SLURM_ARRAY_TASK_ID) to get day-of-year
%

function SDR_j1(year)

more off
addpath ../davet
addpath ../source
addpath ../test

procid = str2num(getenv('SLURM_PROCID'));
nprocs = str2num(getenv('SLURM_NPROCS'));
nodeid = sscanf(getenv('SLURMD_NODENAME'), 'n%d');
taskid = str2num(getenv('SLURM_ARRAY_TASK_ID'));

fprintf(1, 'SDR_j1: processing day %d, year %d, node %d\n', ...
            taskid, year, nodeid);

% SDR_opts_j1(taskid, year)
  SDR_opts_testC(taskid, year)

