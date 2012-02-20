
% compare MIT and NGAS RDR ES, IT, and SP data
%
% This script steps thru the NGAS files for a selected band and FOV.  
% The MIT array sizes are set to the min of the MIT FOR arrays and
% the corresponding NGAS sizes.  The MIT and NGAS data is sorted by
% time, in the MIT case by the associated FOV time.

% original data source for readers
dsrc  = '/asl/data/cris/Proxy/2010/09/06';

% choose a FOV (here and in NGAS var bngs)
fi = 9;

% NGAS matlab RDR data
dngs = '/asl/data/cris/mott/2010/09/06';
% bngs = 'IGMB1F1Packet_000.mat';
bngs = 'IGMB1F9Packet_000.mat';
lngs = dir(sprintf('%s/RMAT*', dngs));

% MIT matlab RDR data
dmit = '/asl/data/cris/mott/2010/09/06mit';

% j = input('input i > ');
% for i = j

for i = 1 : length(lngs)

  % NGAS matlab RDR data
  rid = lngs(i).name(6:23);
  rngs = ['RMAT_', rid];
  fngs = [dngs, '/', rngs, '/', bngs];

  % skip dir if no NGAS files
  if exist(fngs) ~= 2
    % fprintf(1, 'NGAS missing files for %s\n', rid)
    continue
  end

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

  % MIT matlab RDR data
  rmit = ['RDR_', rid, '.mat'];
  fmit = [dmit, '/', rmit];

  % load the MIT data, defines structures d1 and m1
  load(fmit)

  % -------------------
  % do an ES comparison
  % -------------------

  % take the real part of the NGAS data
  ngas1 = real(igmES(:,:));

  % put NGAS data in time-sorted order
  [tx, ix] = sort(PacketDataArray.PacketHeader.Time(iES));
  ngas2 = ngas1(:, ix);

  % take column subset and squeeze MIT data 
  mit1 = squeeze(d1.idata.LWES(1:866,fi,:));

  % trim MIT data to min of FOR and NGAS array sizes
  [m1,n1] = size(ngas2);
  [m2,n2] = size(d1.FOR.LWES);
  n = min([n1, n2]);
  mit2 = mit1(:,1:n);

  % report a size difference
  if n1 ~= n2
    fprintf(1, 'ES index %2d file %s FOV %d NGAS n1=%d, MIT n2=%d\n', ...
            i, rid, fi, n1, n2)
    % keyboard
  end

  % put MIT data in time-sorted order
  [ty, iy] = sort(d1.packet.LWES.time(1:n,fi));
  mit2 = mit2(:, iy);

  % report a data difference
  if ~isequal(ngas2,mit2)
    fprintf(1, 'ES index %2d file %s FOV %d NGAS & MIT data differ\n', ...
            i, rid, fi)
  end

  % -------------------
  % do an IT comparison
  % -------------------

  % take the real part of the NGAS data
  ngas1 = real(igmIT(:,:));

  % put NGAS data in time-sorted order
  [tx, ix] = sort(PacketDataArray.PacketHeader.Time(iIT));
  ngas2 = ngas1(:, ix);

  % take column subset and squeeze MIT data 
  mit1 = squeeze(d1.idata.LWIT(1:866,fi,:));

  % trim MIT data to min of FOR and NGAS array sizes
  [m1,n1] = size(ngas2);
  [m2,n2] = size(d1.FOR.LWIT);
  n = min([n1, n2]);
  mit2 = mit1(:,1:n);

  % report a size difference
  if n1 ~= n2
    fprintf(1, 'IT index %2d file %s FOV %d NGAS n1=%d, MIT n2=%d\n', ...
            i, rid, fi, n1, n2)
  end

  % put MIT data in time-sorted order
  [ty, iy] = sort(d1.packet.LWIT.time(1:n,fi));
  mit2 = mit2(:, iy);

  % report a data difference
  if ~isequal(ngas2,mit2)
    fprintf(1, 'IT index %2d file %s FOV %d NGAS & MIT data differ\n', ...
            i, rid, fi)
  end

  % -------------------
  % do an SP comparison
  % -------------------

  % take the real part of the NGAS data
  ngas1 = real(igmSP(:,:));

  % put NGAS data in time-sorted order
  [tx, ix] = sort(PacketDataArray.PacketHeader.Time(iSP));
  ngas2 = ngas1(:, ix);

  % take column subset and squeeze MIT data 
  mit1 = squeeze(d1.idata.LWSP(1:866,fi,:));

  % trim MIT data to min of FOR and NGAS array sizes
  [m1,n1] = size(ngas2);
  [m2,n2] = size(d1.FOR.LWSP);
  n = min([n1, n2]);
  mit2 = mit1(:,1:n);

  % report a size difference
  if n1 ~= n2
    fprintf(1, 'SP index %2d file %s FOV %d NGAS n1=%d, MIT n2=%d\n', ...
            i, rid, fi, n1, n2)
  end

  % put MIT data in time-sorted order
  [ty, iy] = sort(d1.packet.LWSP.time(1:n,fi));
  mit2 = mit2(:, iy);

  % report a data difference
  if ~isequal(ngas2,mit2)
    fprintf(1, 'SP index %2d file %s FOV %d NGAS & MIT data differ\n', ...
            i, rid, fi)
  end

end

