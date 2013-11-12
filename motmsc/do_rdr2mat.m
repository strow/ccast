
more off
addpath ../source

hdir = '/asl/data/cris/rdr60/hdf/2013/';    % HDF RDR files
gdir = '/asl/data/cris/sdr60/hdf/2013/';    % HDF GCRSO files
mdir = '/asl/data/cris/ccast/rdr60/2013/';  % matlab RDR files
odir = '/asl/data/cris/ccast/daily/2013/';  % matlab daily files

for i = 265 : 273
  doy = sprintf('%03d', i);
  rdr2mat(doy, hdir, mdir);
  sci_daily(doy, mdir, odir); 
  geo_daily(doy, gdir, odir);
end

