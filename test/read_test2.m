%
% basic RDR read test for the new MIT libs
%

% clear all
warning off
rmpath ../readers/MITreader380a
rmpath ../readers/MITreader380a/CrIS
warning on
addpath ../readers/MITreader380b
addpath ../readers/MITreader380b/CrIS
% which read_cris_hdf5_rdr

btrim = 'btrim_cache.mat';
ctmp = 'rdr_packets.dat';
rdir = '/asl/data/cris/rdr60/2017/177';
% rdir = '/umbc/lustre/strow/asl/data/cris/ccast/rdr_test';
rgran = 'RCRIS-RNSCA_npp_d20170626_t1946054_e1954054_b29346_c20170627015417384209_noau_ops.h5';
rfile = fullfile(rdir, rgran);

delete(ctmp)
% profile clear
% profile on
tic
[d1, m1] = read_cris_hdf5_rdr(rfile, ctmp, btrim);
toc
% profile report

