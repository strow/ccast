%
% basic RDR read test for the old MIT libs
%

% clear all
warning off
rmpath ../readers/MITreader380b
rmpath ../readers/MITreader380b/CrIS
warning on 
addpath ../readers/MITreader380a
addpath ../readers/MITreader380a/CrIS
% which read_cris_hdf5_rdr

btrim = 'btrim_cache.mat';
ctmp = 'rdr_packets.dat';
rdir = '/asl/data/cris/rdr60/2017/177';
rgran = 'RCRIS-RNSCA_npp_d20170626_t1946054_e1954054_b29346_c20170627015417384209_noau_ops.h5';
rfile = fullfile(rdir, rgran);

delete(ctmp)
% profile clear
% profile on
tic
[d2, m2] = read_cris_hdf5_rdr(rfile, ctmp, btrim);
toc
% profile report

