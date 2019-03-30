%
% SDR_j1 - ccast L1a to SDR with task ID as day-of-year
%
% SYNOPSIS
%   SDR_j1(year)
%

function SDR_j1(year)

more off
addpath ../source
addpath /asl/packages/airs_decon/source

procid = str2num(getenv('SLURM_PROCID'));
nprocs = str2num(getenv('SLURM_NPROCS'));
nodeid = sscanf(getenv('SLURMD_NODENAME'), '%s');
taskid = str2num(getenv('SLURM_ARRAY_TASK_ID'));

fprintf(1, 'SDR_j1: processing day %d, year %d, node %s\n', ...
            taskid, year, nodeid);

% opts_j1v4_HR(year, taskid)
% opts_j1_LR(year, taskid)
  opts_j1_HR(year, taskid)

