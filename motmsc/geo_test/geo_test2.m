
% simple geo benchmark

% get some 60-scan geo files
doy = '141';
gdir = '/asl/data/cris/sdr60/hdf/2012/';
gsrc = fullfile(gdir, doy);

% list all the geo files for this date
glist = dir(fullfile(gsrc, 'GCRSO_npp*.h5'));

for i = 51 : 54
  gfile = fullfile(gsrc, glist(i).name); 
  [geo1, ag1, at1] = read_GCRSO_60(gfile);
  [geo2, ag2, at2] = read_GCRSO2(gfile);
  geo3 = read_GCRSO(gfile); 

  [isequal(geo1, geo2), isequal(ag1, ag2), ...
   isequal(at1, at2), isequal(geo1, geo3)]
end

% get some 4-scan geo files
doy = '141';
gdir = '/asl/data/cris/sdr4/hdf/2012/';
gsrc = fullfile(gdir, doy);

% list all the geo files for this date
glist = dir(fullfile(gsrc, 'GCRSO_npp*.h5'));

for i = 51 : 60
  gfile = fullfile(gsrc, glist(i).name); 
  geo1 = read_GCRSO(gfile);
  [geo2, ag2, at2] = read_GCRSO2(gfile, 1);

  ag2
  at2
  isequal(geo1, geo2)
  pause
end

