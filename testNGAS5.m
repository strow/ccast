
% compare MIT and NGAS RDR ES and time data
%
% derived from testMIT3.m, an MIT time test, and tesNGAS4.m, 
% a script to compare MIT and NGAS ES, IT and SP data.
% 
% this script takes data with good MIT time fields and where the 
% MIT and NGAS ES data agree and solves for a linear relationship
% between the MIT and NGAS time values, as a check.
%
% Observations:
% 
% NGAS and geo time appears to be milliseconds since 1 Jan 1958,
% roughly 52.7 * 365.25 * 24 * 60 * 60 * 1000
% 
% t_mit * 8.64e7 = t_ngas.  There are 8.64e7 ms in a day, so the 
% MIT time is days since 1 Jan 1958
%
% The time in the test data is about 200 ms between the ES FORs and
% about 2 sec and between ES scans, in agreement with the ATBD spec
%
% The NGAS FOR numbering for DS and IT is reversed, they have IT=0
% and SP=31.  According to the ATBD SP=0 and IT=31; the MIT reader
% follows that.

% test value for weights
awt = 8.64e7;
bwt = 0;

% original data source for readers
dsrc  = '/asl/data/cris/Proxy/2010/09/06';

% choose a FOV for ES comparisons here and in NGAS var bngs
fi = 2;

% NGAS matlab RDR data
dngs = '/asl/data/cris/mott/2010/09/06';
% bngs = 'IGMB1F1Packet_000.mat';
bngs = 'IGMB1F2Packet_000.mat';
lngs = dir(sprintf('%s/RMAT*', dngs));

% MIT matlab RDR data
dmit = '/asl/data/cris/mott/2010/09/06mit';

% abr saves weights a, b, and residual r, ix is size
abr = zeros(4, length(lngs));
nt = 0;

for i = 1 : length(lngs)

  % NGAS matlab RDR data
  rid = lngs(i).name(6:23);
  rngs = ['RMAT_', rid];
  fngs = [dngs, '/', rngs, '/', bngs];

  % skip dir if no NGAS files
  if exist(fngs) ~= 2
    fprintf(1, 'NGAS missing files for %s\n', rid)
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

  % ----------------------------------------
  % check the MIT time field for consistency
  % ----------------------------------------

  % we really should not need to do this, but...
  % choose min dimension over all FOR and time arrays
  [mx,n1] = size(d1.FOR.LWES);
  [mx,n2] = size(d1.FOR.MWES);
  [mx,n3] = size(d1.FOR.SWES);
  [n4,mx] = size(d1.packet.LWES.time);
  [n5,mx] = size(d1.packet.MWES.time);
  [n6,mx] = size(d1.packet.SWES.time);
  n = min([n1,n2,n3,n4,n5,n6]);

  % loop on obs indices
  k = 0;
  for j = 1 : n
    d3 = diff([d1.packet.LWES.time(j,:), ...
               d1.packet.MWES.time(j,:), ...
               d1.packet.SWES.time(j,:)]);

    if ~isequal(d3, zeros(1,26))
      % fprintf(1, 'times differ %d %d\n', i, j)
      k = k + 1;
    end
  end
  if k > 0
    fprintf(1, 'record %2d file %s, %d FOV times differ\n', i, rid, k)
    continue
  end

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
  end

  % put MIT data in time-sorted order
  [ty, iy] = sort(d1.packet.LWES.time(1:n,fi));
  mit2 = mit2(:, iy);

  % report a data difference
  if ~isequal(ngas2,mit2)
    fprintf(1, 'ES index %2d file %s FOV %d NGAS & MIT data differ\n', ...
            i, rid, fi)
  else
    % if data matches, solve for time transform
    tx = tx(:); ty = ty(:);
    if isequal(size(tx), size(ty))
      [m2,n2] = size(tx);
      ab = [ty, ones(m2,n2)] \ tx;
      r1 = rms((ty .* ab(1) + ab(2)) - tx) / rms(tx);
      r2 = rms((ty .* awt + bwt) - tx) / rms(tx);
      nt = nt + 1;
      abr(1:2, nt) = ab;
      abr(3, nt) = r1;
      abr(4, nt) = r2;
      % fprintf(1, 'index %2d time residual %g\n', i, r)
    end
  end

end

% check time fit
max(abr(4, 1:nt))

