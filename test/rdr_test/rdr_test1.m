
p1 = '/asl/data/cris/rdr60/2016/148';
r1 = 'RCRIS-RNSCA_npp_d20160527_t2215254_e2223253_b23743_c20160528042343599711_noaa_ops.h5';

h5Filename = fullfile(p1, r1);
saveFilename = 'packets.dat';

extract_hdf5_rdr(h5Filename, saveFilename)


