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

procid = str2num(getenv('SLURM_PROCID'));
nprocs = str2num(getenv('SLURM_NPROCS'));
nodeid = sscanf(getenv('SLURMD_NODENAME'), 'n%d');
taskid = str2num(getenv('SLURM_ARRAY_TASK_ID'));

fprintf(1, 'ccast_batch: processing day %d, year %d, node %d\n', ...
            taskid, year, nodeid);

% ccast_lowres(taskid, year)
% ccast_hires2(taskid, year)
% ccast_hires3(taskid, year)
% ccast_h2tolow(taskid, year)
  ccast_h3tolow(taskid, year)

