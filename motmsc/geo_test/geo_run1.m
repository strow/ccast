
% run off a set of geo_daily data

% geo data source
gdir = '/asl/data/cris/sdr60/hdf/2012/';

% output directory
odir = '/home/motteler/cris/data/2012/daily/';  

% initial orbit start time
orbst1 = NaN;

for i = 129 : 212

  doy = sprintf('%03d', i);

  fprintf(1, '--- doy %s, orbit start time %d ---\n', doy, orbst1)

  orbst2 = geo_daily(doy, gdir, odir, orbst1);

  orbst1 = orbst2;

end

