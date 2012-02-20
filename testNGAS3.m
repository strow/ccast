
% compare MIT and NGAS RDR ES, IT, and SP data
%
% this version steps thru all NGAS files for a selected band and
% FOV and sorts both the MIT and NGAS data by time.  The MIT data
% is sorted by the FOV 1 time, for whatever reason that worked
% while the FOV 5 time didn't.

% original data source for readers
dsrc  = '/asl/data/cris/Proxy/2010/09/06';

% NGAS matlab RDR data
dngs = '/asl/data/cris/mott/2010/09/06';
bngs = 'IGMB1F1Packet_000.mat';
lngs = dir(sprintf('%s/RMAT*', dngs));

% MIT matlab RDR data
dmit = '/asl/data/cris/mott/2010/09/06mit';

j = input('input i > ');
for i = j

% for i = 1 : length(lngs)

  % skip dir if no NGAS files
  if exist([dngs, '/', lngs(i).name, '/', bngs]) ~= 2
    continue
  end

  % NGAS matlab RDR data
  rid = lngs(i).name(6:23);
  rngs = ['RMAT_', rid];
  fngs = [dngs, '/', rngs, '/', bngs];

  % MIT matlab RDR data
  rmit = ['RDR_', rid, '.mat'];
  fmit = [dmit, '/', rmit];

  % load the MIT data, defines structures d1 and m1
  load(fmit)

  % load the NGAS data, defines structure PacketDataArray
  load(fngs)

  % PacketDataArray.ScanInfo.FOR cycles thru [0,0,1:30,31,31] and may
  % start anywhere.  PacketDataArray.ScanInfo.SweepDir alternates 0, 2

  iES = 1 <= PacketDataArray.ScanInfo.FOR & PacketDataArray.ScanInfo.FOR <= 30;
  iIT = PacketDataArray.ScanInfo.FOR == 0;
  iSP = PacketDataArray.ScanInfo.FOR == 31;

  igmES = PacketDataArray.IGM(:,iES); 
  igmIT = PacketDataArray.IGM(:,iIT); 
  igmSP = PacketDataArray.IGM(:,iSP); 

  % -------------------
  % do an ES comparison
  % -------------------
  a1 = real(igmES(:,:));
  a2 = squeeze(d1.idata.LWES(1:866,1,:));

  % put NGAS time in sorted order
  [tx, ix] = sort(PacketDataArray.PacketHeader.Time(iES));
  b1 = a1(:, ix);

  % trim MIT data 
  [m,n] = size(b1);
  b2 = a2(:,1:n);

  % report a size difference
  [u,v] = size(a2);
  if v ~= n
    fprintf(1, 'NGAS ES %4d, MIT ES %4d, index %d file %s\n', n, v, i, rid)
  end

  % put MIT time in sorted order
  [ty, iy] = sort(d1.packet.LWES.time(1:n,1));
  b2 = b2(:, iy);

  if ~isequal(b1,b2)
    fprintf(1, '*** NGAS & MIT ES differ index %d file %s\n', i, rid)
    d1.idata
  end

  % -------------------
  % do an IT comparison
  % -------------------
  a1 = real(igmIT(:,:));
  a2 = squeeze(d1.idata.LWIT(1:866,1,:));

  % put NGAS time in sorted order
  [tx, ix] = sort(PacketDataArray.PacketHeader.Time(iIT));
  b1 = a1(:, ix);

  % trim MIT data
  [m,n] = size(b1);
  b2 = a2(:,1:n);

  % report a size difference
  [u,v] = size(a2);
  if v ~= n
    fprintf(1, 'NGAS IT %4d, MIT IT %4d, index %d file %s\n', n, v, i, rid)
  end

  % put MIT time in sorted order
  [ty, iy] = sort(d1.packet.LWIT.time(1:n,1));
  b2 = b2(:, iy);

  if ~isequal(b1,b2)
    fprintf(1, '*** NGAS & MIT IT differ index %d file %s\n', i, rid)
    d1.idata
  end

  % -------------------
  % do an SP comparison
  % -------------------
  a1 = real(igmSP(:,:));
  a2 = squeeze(d1.idata.LWSP(1:866,1,:));

  % put NGAS time in sorted order
  [tx, ix] = sort(PacketDataArray.PacketHeader.Time(iSP));
  b1 = a1(:, ix);

  % trim MIT data
  [m,n] = size(b1);
  b2 = a2(:,1:n);

  % report a size difference
  [u,v] = size(a2);
  if v ~= n
    fprintf(1, 'NGAS SP %4d, MIT SP %4d, index %d file %s\n', n, v, i, rid)
  end

  % put MIT time in sorted order
  [ty, iy] = sort(d1.packet.LWSP.time(1:n,1));
  b2 = b2(:, iy);

  if ~isequal(b1,b2)
    fprintf(1, '*** NGAS & MIT SP differ index %d file %s\n', i, rid)
    d1.idata
  end

end

