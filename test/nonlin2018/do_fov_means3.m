%
% compare means for npp and j1/n20
%

addpath ../source
addpath ../motmsc/utils
addpath /asl/packages/airs_decon/source

dsrc = '/asl/data/cris/ccast/sdr45_npp_HR';
dout = 'npp_n20_54-85_1';
fout = fullfile(dout, 'npp_mean');

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
dlist = 54:85;
% iFOR = 14:17;
  iFOR = 1:30;
rng(seed);
cris_fov_means(year, dlist, iFOR, dsrc, fout);

