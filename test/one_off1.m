
addpath ../source
addpath ../motmsc/utils
addpath ../test/nonlin2018

year = 2018;
dlist = 31:46;
iFOR = 14:17;
dpath = '/asl/data/cris/ccast/sdr45_npp_HR';
sfile = 'npp_umbc'
cris_fov_means(year, dlist, iFOR, dpath, sfile)

