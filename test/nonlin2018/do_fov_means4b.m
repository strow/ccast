%
% compare means for npp and j1/n20 with "a2_test1" weights
%

addpath ../source
addpath ../motmsc/utils

dsrc = '/asl/data/cris/ccast/a2_test1/sdr45_j01_HR';
dout = 'npp_n20_54_63';
fout = fullfile(dout, 'a1_test1');

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
dlist = 54:63;
iFOR = 14:17;
rng(seed);
cris_fov_means(year, dlist, iFOR, dsrc, fout);

