%
% basic RDR read test for new J1 data
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
ctmp = 'rdr_j1_packets.dat';
rdir = '/asl/data/cris2/CRIS-SCIENCE-RDR_SPACECRAFT-DIARY-RDR/20171201';
% rgran = 'RCRIS-RNSCA_j01_d20171201_t1302558_e1303277_b00187_c20171201141021226519_nobu_ops.h5';
% rgran = 'RCRIS-RNSCA_j01_d20171201_t0907451_e0908171_b00184_c20171201101038343110_nobu_ops.h5';

rlist = dir(fullfile(rdir, 'RCRIS-RNSCA_j01*.h5'));

for fi = 1 : length(rlist)

  rfile = fullfile(rdir, rlist(fi).name);

  delete(ctmp)
  [d1, m1] = read_cris_hdf5_rdr(rfile, ctmp, btrim);

  if d1.packet.read_four_min_packet
    keyboard
  end

end

