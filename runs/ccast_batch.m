%
% ccast_batch -- run ccast on doy d1 + procid
%

function ccast_batch(d1, year)

more off
addpath /home/motteler/cris/ccast/davet
addpath /home/motteler/cris/ccast/motmsc
addpath /home/motteler/cris/ccast/motmsc/utils
addpath /home/motteler/cris/ccast/source

procid = str2num(getenv('SLURM_PROCID'));
nprocs = str2num(getenv('SLURM_NPROCS'));

% fprintf(1, 'ccast_batch: procid %d, nprocs %d, start day %d\n', ...
%             procid, nprocs, d1)

fprintf(1, 'ccast_batch: processing day %d, year %d\n', d1 + procid, year)

ccast_main(d1 + procid, year)



