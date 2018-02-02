%
% do_fov_means - cal cris_fov_means on a list of directories
%

addpath ../source
addpath ../motmsc/utils

  dout = 'a2_set3_1';
% dout = 'a2_algo_3';

%tlist = {'a2v4_old', 'a2v4_new'}

% tlist = {'j1v3_a2new'}
% tlist = {'a2v3_p25', 'a2v3_m30', 'a2v3_m35'}

% tlist = {'a2v3_m05', 'a2v3_m10', 'a2v3_m15', 'a2v3_m20', ...
%          'a2v3_m25', 'a2v3_m30', 'a2v3_m35', ...
%          'a2v3_p05', 'a2v3_p10', 'a2v3_p15', 'a2v3_p20', ...
%          'a2v3_p25', 'a2v3_p30', 'a2v3_ref'};

  tlist = {'a2v3_p60', 'a2v3_p80', 'a2v3_p100'};

tdir2 = 'sdr45_j01_HR';
chome = '/asl/data/cris/ccast';

rng('shuffle');
seed = rng;

for i = 1 : length(tlist)
  tdir1 =  tlist{i};
  fprintf(1, 'processing %s\n', tdir1)
  dpath = fullfile(chome, tdir1, tdir2);
  sfile = fullfile(dout, tdir1);
  rng(seed);
  cris_fov_means(2018, 21:27, 14:17, dpath, sfile)
end

