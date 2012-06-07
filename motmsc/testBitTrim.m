
dsrc = '/asl/data/cris/mott/2010/09/06mit/';

dlist = dir(sprintf('%s/RDR*.mat', dsrc));

tlist = 2*length(dlist);

b1 = 0; b2 = 0; b3 = 0;

for i = 1 : length(dlist)

  mfile = [dsrc, '/', dlist(i).name];
  load(mfile)

  % the load gets instrument and meta data from the call
  % [d1, m1] = read_cris_hdf5_rdr(h5file);

  if isfield(d1.packet, 'BitTrimMask')
    a1 = d1.packet.BitTrimMask.Band(1).StopBit(:);
    a2 = d1.packet.BitTrimMask.Band(1).StartBit(:);
    a3 = d1.packet.BitTrimMask.Band(1).Index(:);
%   a1 = d1.packet.BitTrimMask.Band(1).StopBit;
%   a2 = d1.packet.BitTrimMask.Band(1).StartBit;
%   a3 = d1.packet.BitTrimMask.Band(1).Index;
  else
    fprintf(1, 'no bit trim mask in record %d, %s\n', i, dlist(i).name);
    continue
  end


  t1 = m1.CRIS_SCIENCE_RDR.N_Beginning_Time_IET;
  t2 = m1.CRIS_SCIENCE_RDR.N_Ending_Time_IET;

  tlist(2*(i-1) + 1) = t1;
  tlist(2*(i-1) + 2) = t2;

  if i > 1 && (~isequal(a1,b1) || ~isequal(a2,b2) || ~isequal(a3,b3))
    fprintf(1, 'bit trim mask changed at record %d, %s\n', i, dlist(i).name);
  end

  b1 = a1; b2 = a2; b3 = a3;

end

