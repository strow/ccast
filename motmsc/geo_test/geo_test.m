
% simple geo benchmark

% get some geo files
doy = '112';
gdir = '/asl/data/cris/sdr60/hdf/2012/';
gsrc = fullfile(gdir, doy);

% list all the geo files for this date
glist = dir(fullfile(gsrc, 'GCRSO_npp*.h5'));

% call Scott's geo reader
tic
for i = 1 : 20
  gfile = fullfile(gsrc, glist(i).name); 
  geo1 = readsdr_rawgeo(gfile);
end
toc

% cal new H5 libs reader
% profile clear
% profile on
tic
for i = 1 : 20
  gfile = fullfile(gsrc, glist(i).name); 
  % geo2 = read_GCRSO(gfile);
  % geo2 = read_GCRSO_60(gfile);
  [geo2, attr60] = read_GCRSO_60(gfile);
  % [geo2, attr60, attr4] = read_GCRSO_60(gfile);
end
toc
% profile viewer

% check results
isequal(geo1, geo2)

