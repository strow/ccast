
more off
addpath /home/motteler/cris/ccast/davet
addpath /home/motteler/cris/ccast/source
addpath /home/motteler/cris/ccast/motmsc
addpath /home/motteler/cris/ccast/motmsc/utils

hdir = '/asl/data/cris/rdr60/hdf/2013/';    % HDF RDR files
gdir = '/asl/data/cris/sdr60/hdf/2013/';    % HDF GCRSO files
mdir = '/asl/data/cris/ccast/rdr60/2013/';  % matlab RDR files
odir = '/asl/data/cris/ccast/daily/2013/';  % matlab daily files

for i = [4, 136]
  doy = sprintf('%03d', i);
  rdr2mat(doy, hdir, mdir);
  sci_daily(doy, mdir, odir); 
  geo_daily(doy, gdir, odir);
end

