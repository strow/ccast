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
rdir = '/asl/data/cris2/CRIS-SCIENCE-RDR_SPACECRAFT-DIARY-RDR/20180104';

rlist = dir(fullfile(rdir, 'RCRIS-RNSCA_j01*.h5'));

% for fi = 1 : length(rlist)
for fi = length(rlist)-20 : length(rlist)

  rfile = fullfile(rdir, rlist(fi).name);

  delete(ctmp)
  [d1, m1] = read_cris_hdf5_rdr(rfile, ctmp, btrim);

  if d1.packet.read_four_min_packet
    engp = struct;
    [sci, eng] = scipack(d1, engp);
  end
end

datestr(utc2dnum(sci(1).time/1000))
[wlaser,mtime] = metlaser(eng.NeonCal)
[sci(1).T_PRT1, sci(1).T_PRT2]


