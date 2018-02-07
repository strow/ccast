%
% call cris_fov_means with common rng seed on a list of directories
%

addpath ../source
addpath ../motmsc/utils

dout = 'a2v4_set_3';

% tlist = {'atbd_m05', 'atbd_m10', 'atbd_m15', 'atbd_m20', ...
%          'atbd_p05', 'atbd_p10', 'atbd_p15', 'atbd_p20', 'atbd_ref'};

  tlist = {'a2v4_m10', 'a2v4_m20', ...
           'a2v4_p05', 'a2v4_p10', 'a2v4_p20'};

% tlist = {'a2v4_ref'};

tdir2 = 'sdr45_j01_HR';
chome = '/asl/data/cris/ccast';

sfile = fullfile(dout, 'seed.mat');

if exist(sfile) == 2
  load(sfile)
  fprintf(1, 'using existing seed...\n')
else
  rng('shuffle');
  seed = rng;
  save(sfile, 'seed');
  fprintf(1, 'creating and saving a new seed...\n')
end

for i = 1 : length(tlist)
  tdir1 =  tlist{i};
  fprintf(1, 'processing %s\n', tdir1)
  dpath = fullfile(chome, tdir1, tdir2);
  sfile = fullfile(dout, tdir1);
  rng(seed);
  cris_fov_means(2018, 21:27, 14:17, dpath, sfile)
end

