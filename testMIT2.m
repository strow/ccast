
% basic validation tests for MIT reader

dsrc = '/asl/data/cris/mott/2010/09/06mit';

dlist = dir(sprintf('%s/RDR*.mat', dsrc));

% loop on MIT RDR matlab files

for ir = 1 : length(dlist)

  mfile = [dsrc, '/', dlist(ir).name];
  load(mfile)

  % the load gets instrument and meta data from the call
  % [d1, m1] = read_cris_hdf5_rdr(h5file);

  [d1.FOR.LWES(5,1:8);
   d1.FOR.LWIT(5,1:8)]

  % basic scan geometry sanity check
  [m,n,nES] = size(d1.idata.LWES);
  [m,n,nIT] = size(d1.idata.LWIT);
  nscan = nES / 30;
  ncals = nIT / 2;
  if ncals < nscan
    fprintf(1, 'scan geometry error, skipping file %d\n', ir);
    continue
  end

  % basic obs time sanity check
  tok = d1.packet.LWSP.time(1,5) < d1.packet.LWIT.time(1,5) && ...
        d1.packet.LWIT.time(1,5) < d1.packet.LWES.time(1,5);
  if ~tok
    fprintf(1, 'packets not it time order, skipping file %d\n', ir)
    continue
  end

  % build calibration averages

end

