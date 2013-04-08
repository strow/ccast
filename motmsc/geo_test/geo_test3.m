
% simple geo test

% get some 60-scan geo files
doy = '141';
gdir = '/asl/data/cris/sdr60/hdf/2012/';
gsrc = fullfile(gdir, doy);

% list all the geo files for this date
glist = dir(fullfile(gsrc, 'GCRSO_npp*.h5'));

for i = 51 : 54
  gfile = fullfile(gsrc, glist(i).name); 
  [geo1, ag1, at1] = read_GCRSO(gfile);

  geo2 = readsdr_rawgeo(gfile);

  isequal(geo1, geo2)

end

