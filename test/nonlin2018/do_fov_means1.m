%
% call cris_fov_means with common rng seed on a list of directories
%

addpath ../source
addpath ../motmsc/utils

dsrc = '/asl/data/cris/ccast/sdr45_npp_HR';
dout = 'npp_15-30_3';
fout = fullfile(dout, 'npp_umbc');

rseed = fullfile(dout, 'seed.mat');
if exist(rseed) == 2
  load(rseed)
  fprintf(1, 'using existing seed...\n')
else
  rng('shuffle');
  seed = rng;
  save(rseed, 'seed');
  fprintf(1, 'creating and saving a new seed...\n')
end

year = 2018;
% dlist = 31:46;
  dlist = 15:30;
iFOR = 14:17;
rng(seed);
cris_fov_means(year, dlist, iFOR, dsrc, fout);

