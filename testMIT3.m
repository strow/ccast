
% check FOV time fields in MIT data
% 

% original data source for readers
dsrc  = '/asl/data/cris/Proxy/2010/09/06';

dmit = '/asl/data/cris/mott/2010/09/06mit';

mlist = dir(sprintf('%s/RDR*.mat', dmit));

% loop on MIT RDR matlab files

for ir = 1 : length(mlist)

  rid = mlist(ir).name(5:22);
  mfile = [dmit, '/', mlist(ir).name];
  load(mfile)

  % the load gets instrument and meta data from the call
  % [d1, m1] = read_cris_hdf5_rdr(h5file);

  % we really should not need to do this, but...
  % choose min dimension over all FOR and time arrays
  [m,n1] = size(d1.FOR.LWES);
  [m,n2] = size(d1.FOR.MWES);
  [m,n3] = size(d1.FOR.SWES);
  [n4,m] = size(d1.packet.LWES.time);
  [n5,m] = size(d1.packet.MWES.time);
  [n6,m] = size(d1.packet.SWES.time);
  n = min([n1,n2,n3,n4,n5,n6]);

  k = 0;
  for j = 1 : n
    d3 = diff([d1.packet.LWES.time(j,:), ...
               d1.packet.MWES.time(j,:), ...
               d1.packet.SWES.time(j,:)]);

    if ~isequal(d3, zeros(1,26))
      % fprintf(1, 'times differ %d %d\n', ir, j)
      k = k + 1;
    end
  end
  if k > 0
    fprintf(1, 'record %2d file %s, %d FOV times differ\n', ir, rid, k)
  end
end




