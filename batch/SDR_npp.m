%
% NAME
%   SDR_npp -- run ccast v20 on day-of-year from task ID
%
% SYNOPSIS
%   SDR_npp(year)
%
% DISCUSSION
%  uses job array task ID (SLURM_ARRAY_TASK_ID) to get day-of-year
%

function SDR_npp(year)

more off
addpath ../davet
addpath ../source
addpath ../test

procid = str2num(getenv('SLURM_PROCID'));
nprocs = str2num(getenv('SLURM_NPROCS'));
nodeid = sscanf(getenv('SLURMD_NODENAME'), 'n%d');
taskid = str2num(getenv('SLURM_ARRAY_TASK_ID'));

fprintf(1, 'SDR_npp: processing day %d, year %d, node %d\n', ...
            taskid, year, nodeid);

SDR_opts_npp(taskid, year)

