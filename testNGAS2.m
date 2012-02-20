
% compare MIT and NGAS RDR ES data
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

  ibad = PacketDataArray.ScanStatusFlag.InvalidData(iES);

  igmES = PacketDataArray.IGM(:,iES); 

  a1 = real(igmES(:,:));
  a2 = squeeze(d1.idata.LWES(1:866,1,:));

  % put NGAS time in sorted order
  [tx, ix] = sort(PacketDataArray.PacketHeader.Time(iES));
  b1 = a1(:, ix);

  % trim MIT data 
  [m,n] = size(b1);
  b2 = a2(:,1:n);

  % put MIT time in sorted order
  [ty, iy] = sort(d1.packet.LWES.time(1:n,1));
  b2 = b2(:, iy);

  if ~isequal(b1,b2)
    fprintf(1, 'NGAS & MIT differ index %d file %s\n', i, rid)
    d1.idata
  end

end

