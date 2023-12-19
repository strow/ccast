%
% quick RDR read test to get eng packets
%

addpath /home/motteler/cris/ccast/readers/MITreader380b
addpath /home/motteler/cris/ccast/readers/MITreader380b/CrIS

% path to an RDR granule
  p1 = '/asl/cris/rdr60_j02/2023/052';
  g1 = 'RCRIS-RNSCA_j02_d20230221_t0115155_e0123154_b01458_c20230221013917231423_oeau_ops.h5';
% p1 = '/asl/cris/rdr60_j02/2023/053';
% g1 = 'RCRIS-RNSCA_j02_d20230222_t0115074_e0123073_b01472_c20230222013322008338_oeau_ops.h5';
% p1 = '/asl/cris/rdr60_j02/2023/054';
% g1 = 'RCRIS-RNSCA_j02_d20230223_t0114593_e0122592_b01486_c20230223015250878100_oeau_ops.h5';
f1 = fullfile(p1, g1);

% path to some eng packet, to get the reader started
% (note the eng packet is saved in the struct "eng")
e1 = '/home/motteler/cris/ccast/inst_data/j1_eng_v115_H4.mat';
load(e1);

[DATA META] = read_cris_hdf5_rdr(f1, 'tmpxxx.dat', eng)

eng = DATA.packet;
save(sprintf('j2_eng_v%d', eng.Eng_Packet_Ver), 'eng')


