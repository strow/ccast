%
% SDR_npp - ccast L1a to SDR with task ID as day-of-year
%
% SYNOPSIS
%   SDR_npp(year)
%

function SDR_npp(year)

more off
addpath ../source

procid = str2num(getenv('SLURM_PROCID'));
nprocs = str2num(getenv('SLURM_NPROCS'));
nodeid = sscanf(getenv('SLURMD_NODENAME'), 'n%d');
taskid = str2num(getenv('SLURM_ARRAY_TASK_ID'));

fprintf(1, 'SDR_npp: processing day %d, year %d, node %d\n', ...
            taskid, year, nodeid);

  opts_SDR_npp_LR(taskid, year)
% opts_SDR_npp_HR(taskid, year)

