
load /asl/data/cris/ccast/daily/2014/allgeo20141116.mat

lat = squeeze(allgeo.Latitude(5,15,:));
t1  = squeeze(allgeo.FORTime(15,:));

lat = lat(:);
t1  = t1(:);

iok = -100 < lat & lat < 100 & ~isnan(lat) & t1 > 1e12;

lat = lat(iok);
t1  = t1(iok);
t2  = t1 - t1(1);

aflag = lat2aflag(lat);

plot(t2, lat, t2, aflag * 160 - 80)
grid on; zoom on

