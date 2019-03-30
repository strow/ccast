% 
% sample eng (4 minute) packets from a NOAA RDR file
%

addpath ../source
addpath ../readers/MITreader380b
addpath ../readers/MITreader380b/CrIS

% early npp v36
% gdir = '/asl/cris/rdr60_npp/2015/005';
% gran = 'RCRIS-RNSCA_npp_d20150105_t2244014_e2252013_b16536_c20150106045223758691_noaa_ops.h5';

% late npp v36
% gdir = '/asl/cris/rdr60_npp/2015/221';
% gran = 'RCRIS-RNSCA_npp_d20150809_t0158576_e0206576_b19588_c20150809080719006119_noaa_ops.h5';

% recent npp v37
% gdir = '/asl/cris/rdr60_npp/2019/061';
% gran = 'RCRIS-RNSCA_npp_d20190302_t1223140_e1231140_b38053_c20190302163137328422_nobu_ops.h5';

% recent j1 v115
  gdir = '/asl/cris/rdr60_j01/2019/061';
  gran = 'RCRIS-RNSCA_j01_d20190302_t1207141_e1215141_b06656_c20190302161537147674_nobu_ops.h5';

rfile = fullfile(gdir, gran);
ctmp = 'ccsds_test.tmp';
if exist(ctmp), delete(ctmp), end

% get an eng for the inital read
opts = struct;
load('../inst_data/npp_eng')

[d1, m1] = read_cris_hdf5_rdr(rfile, ctmp, eng);

[sci, eng] = scipack(d1, eng);

% save npp_eng_v36_H2 eng
% save npp_eng_v37_H3 eng
  save j1_eng_v115_H4 eng

