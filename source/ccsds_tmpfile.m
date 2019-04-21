
function ctmp = ccsds_tmpfile

jobid = str2num(getenv('SLURM_JOB_ID'));         % job ID
jarid = str2num(getenv('SLURM_ARRAY_TASK_ID'));  % job array ID
procid = str2num(getenv('SLURM_PROCID'));        % relative process ID
if isempty(jobid) || isempty(jarid) || isempty(procid) ...
    || exist(sprintf('/scratch/%d', jobid), 'dir') == 0
  fprintf(1, 'warning: using current directory for CCSDS temp file\n')
  rng('shuffle');
  ctmp = sprintf('ccsds_%05d.tmp', randi(99999));
else
  ctmp = sprintf('/scratch/%d/ccsds_%03d_%03d.tmp', jobid, jarid, procid);
end

