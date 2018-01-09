%
% basic RDR read test for new J1 data
%

% clear all
addpath ../davet
addpath ../source
addpath ../readers/MITreader380b
addpath ../readers/MITreader380b/CrIS

load('j1_eng')
ctmp = 'j1_packets.tmp';
rdir = '/asl/data/cris2/CRIS-SCIENCE-RDR_SPACECRAFT-DIARY-RDR/20180108';
rlist = dir(fullfile(rdir, 'RCRIS-RNSCA_j01*.h5'));

% for fi = 1 : length(rlist)
for fi = length(rlist)-20 : length(rlist)

  rfile = fullfile(rdir, rlist(fi).name);

  delete(ctmp)
  [d1, m1] = read_cris_hdf5_rdr(rfile, ctmp, eng);

  if d1.packet.read_four_min_packet
    engp = struct;
    [sci, eng] = scipack(d1, engp);
  end
end

datestr(utc2dnum(sci(1).time/1000))
[wlaser,mtime] = metlaser(eng.NeonCal)
[sci(1).T_PRT1, sci(1).T_PRT2]


