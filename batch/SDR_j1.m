%
% SDR_j1 - ccast L1a to SDR with task ID as day-of-year
%
% SYNOPSIS
%   SDR_j1(year)
%

function SDR_j1(year)

more off
addpath ../source

procid = str2num(getenv('SLURM_PROCID'));
nprocs = str2num(getenv('SLURM_NPROCS'));
nodeid = sscanf(getenv('SLURMD_NODENAME'), 'n%d');
taskid = str2num(getenv('SLURM_ARRAY_TASK_ID'));

fprintf(1, 'SDR_j1: processing day %d, year %d, node %d\n', ...
            taskid, year, nodeid);

% opts_j1_HR(year, taskid)
  opts_atbd_ref(year, taskid)
% opts_a2v4_ref(year, taskid)

