
% NGAS matlab RDR data directory
dngs = '/asl/data/cris/rdr60/ng/2012/020';
lngs = dir(sprintf('%s/RMAT*', dngs));

for i = 1 : length(lngs)

  % NGAS matlab RDR data
  rid = lngs(i).name(6:23);
  rngs = ['RMAT_', rid];

  for bi = 1 : 3
    for fi = 1 : 9                                         

      % NGAS filename
      bngs = sprintf('IGMB%dF%dPacket_000.mat', bi, fi);
      fngs = [dngs, '/', rngs, '/', bngs];

      % skip check if no file
      if exist(fngs) ~= 2
        % fprintf(1, 'skipping %s\n', fngs)
        continue
      end

      % load the NGAS file
      % fprintf(1, 'loading %s\n', fngs)
      load(fngs)

      % check the flags
      k = [ max(PacketDataArray.ScanStatusFlag.ImpulseTableMemErr), ...
            max(PacketDataArray.ScanStatusFlag.BitTrimTableMemErr), ...
            max(PacketDataArray.ScanStatusFlag.QCoeffTableMemErr), ...
            max(PacketDataArray.ScanStatusFlag.ICoeffTableMemErr), ...
            max(PacketDataArray.ScanStatusFlag.FCE_Detect) ];
      if sum(k) ~= 0
        fprintf(1, '\nflag set band %d FOV %d file %s\n', bi, fi, rid)
        k
      end
    end
  end
  fprintf(1, '.')
end
fprintf(1, '\n')
