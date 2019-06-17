%
% NAME
%   job_array -- run ccast on doy = job array ID
%
% SYNOPSIS
%   job_array(fnx, year)
%
% fnx values include
%   SDR_npp_LR, SDR_npp_H2, SDR_npp_H3, SDR_j1_LR, SDR_j1_H4,
%   L1a_npp_LR, L1a_npp_H2, L1a_npp_H3, L1a_j1_H4
%

function job_array(fnx, year)

more off
addpath ../source
addpath ../motmsc/time
addpath /asl/packages/airs_decon/source

jobid = str2num(getenv('SLURM_JOB_ID'));          % job ID
jarid = str2num(getenv('SLURM_ARRAY_TASK_ID'));   % job array ID
procid = str2num(getenv('SLURM_PROCID'));         % relative process ID
nprocs = str2num(getenv('SLURM_NTASKS'));         % number of tasks
nodeid = sscanf(getenv('SLURMD_NODENAME'), '%s'); % node name

doy = jarid;

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
  case 'SDR_npp_H2',  opts_SDR_npp_H2(year, doy);
  case 'SDR_npp_H3',  opts_SDR_npp_H3(year, doy);
  case 'SDR_j1_LR',   opts_SDR_j1_LR(year, doy);
  case 'SDR_j1_H4',   opts_SDR_j1_H4(year, doy);
  case 'L1a_npp_LR',  opts_L1a_npp_LR(year, doy);
  case 'L1a_npp_H2',  opts_L1a_npp_H2(year, doy);
  case 'L1a_npp_H3',  opts_L1a_npp_H3(year, doy);
  case 'L1a_j1_H4',   opts_L1a_j1_H4(year, doy);
  otherwise, error('bad fnx spec')
end

