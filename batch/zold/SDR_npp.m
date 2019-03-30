%
% SDR_npp - ccast L1a to SDR with task ID as day-of-year
%
% SYNOPSIS
%   SDR_npp(year)
%

function SDR_npp(year)

more off
addpath ../source
addpath /asl/packages/airs_decon/source

procid = str2num(getenv('SLURM_PROCID'));
nprocs = str2num(getenv('SLURM_NPROCS'));
nodeid = sscanf(getenv('SLURMD_NODENAME'), '%s');
taskid = str2num(getenv('SLURM_ARRAY_TASK_ID'));

fprintf(1, 'SDR_npp: processing day %d, year %d, node %s\n', ...
            taskid, year, nodeid);

% opts_npp_LR(year, taskid)
  opts_npp_HR(year, taskid)

