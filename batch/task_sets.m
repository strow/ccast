%
% NAME
%   task_sets -- run ccast on doy = job array ID + process ID
%
% SYNOPSIS
%   task_sets(fnx, year)
%
% fnx values include
%   SDR_npp_LR, SDR_npp_HR, SDR_j1_LR, SDR_j1_HR,
%   L1a_npp_H2, L1a_npp_H3, L1a_j1_H4
%
% sample doy base for 24 task sets starting 1 Jan:
%   1,25,49,73,97,121,145,169,193,217,241,265,289,313,337,361
%

function task_sets(fnx, year)

more off
addpath ../source
addpath ../motmsc/time
addpath /asl/packages/airs_decon/source

jobid = str2num(getenv('SLURM_JOB_ID'));         % job ID
jarid = str2num(getenv('SLURM_ARRAY_TASK_ID'));  % job array ID
procid = str2num(getenv('SLURM_PROCID'));        % relative process ID
nprocs = str2num(getenv('SLURM_NTASKS'));        % number of tasks
nodeid = sscanf(getenv('SLURMD_NODENAME'), '%s');

doy = jarid + procid;

if isleap(year), yend = 366; else, yend = 365; end
if doy > yend
  fprintf(1, 'ccast %s: ignoring %d doy %d\n', fnx, year, doy)
  return
end

fprintf(1, 'ccast %s: processing day %d, year %d, node %s\n', ...
            fnx, doy, year, nodeid);

fprintf(1, 'job ID %d\n', jobid)
fprintf(1, 'job array ID %d\n', jarid)
fprintf(1, 'process ID %d\n', procid)

switch fnx
  case 'SDR_npp_LR',  opts_SDR_npp_LR(year, doy);
  case 'SDR_npp_HR',  opts_SDR_npp_HR(year, doy);
  case 'SDR_j1_LR',   opts_SDR_j1_LR(year, doy);
  case 'SDR_j1_HR',   opts_SDR_j1_HR(year, doy);
  case 'L1a_npp_H2',  opts_L1a_npp_H2(year, doy);
  case 'L1a_npp_H3',  opts_L1a_npp_H3(year, doy);
  case 'L1a_j1_H4',   opts_L1a_j1_H4(year, doy);
  otherwise, error('bad fnx spec')
end

