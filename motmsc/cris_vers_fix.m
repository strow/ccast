%
% fix NPP H2 version numbers
%

% NPP fixes
% year = 2014;
% dlist = 339 : 365;
% year = 2015;
% dlist = 1 : 306;
% year = 2019;
% dlist = 176 : 365;
% year = 2020;
% dlist = 1:32;

% J1 fix
% year = 2019;
% dlist = 197:365;
  year = 2020;
  dlist = 1:65;

% set up source paths
addpath /home/motteler/cris/ccast/source
addpath /home/motteler/cris/ccast/motmsc/time
addpath /home/motteler/shome/airs_decon/source

% CrIS and CHIRP local data homes
ahome = '/asl/cris/ccast/sdr45_j01_HR';

% CrIS and CHIRP annual data (home/yyyy)
ayear = fullfile(ahome, sprintf('%d', year));

% loop on days of the year
for di = dlist

  % add day-of-year to paths
  doy = sprintf('%03d', di);
  fprintf(1, 'processing %d doy %s\n', year, doy)
  apath = fullfile(ayear, doy);

  % check that the source path exists
  if exist(apath) ~= 7
    fprintf(1, '%s: bad source path %s\n', fstr, apath)
    continue
  end

  % loop on CrIS granules
  flist = dir(fullfile(apath, 'CrIS_SDR_j01*_v20a.mat'));
  for fi = 1 : length(flist)

    agran = fullfile(apath, flist(fi).name);
    ftmp = strrep(flist(fi).name, 'v20a', 'v20d');
    dgran = fullfile(apath, ftmp);

    s = movefile(agran, dgran);
    if s == 0, error('move failed'), end

  end % loop on granules
end % loop on days

