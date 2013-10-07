
more off
addpath ../source

gdir = '/asl/data/cris/sdr60/hdf/2013/';  % HDF GCRSO files
odir = '/home/motteler/cris/data/2013/daily/';  % matlab daily files

for i = 107 : 116
  doy = sprintf('%03d', i);
  geo_daily(doy, gdir, odir);
end

