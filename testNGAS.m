
% compare MIT and NGAS RDR data

% original data source for readers
dsrc  = '/asl/data/cris/Proxy/2010/09/06';

% select mat files from timestamp in RDR filenames
% rid  = 'd20100906_t0706030';
% rid  = 'd20100906_t0330042';
rid  = 'd20100906_t0610033';

% MIT matlab RDR data
dmit = '/asl/data/cris/mott/2010/09/06mit';
rmit = ['RDR_', rid, '.mat'];
fmit = [dmit, '/', rmit];

% NGAS matlab RDR data
dngs = '/asl/data/cris/mott/2010/09/06';
rngs = ['RMAT_', rid];
bngs = 'IGMB1F1Packet_000.mat';
fngs = [dngs, '/', rngs, '/', bngs];

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
isequal(b1,a2)


% i = 1 : 240;
% for j = 1 : 240: 1800
%   isequal(a1(:,i), a2(:,j:j+240-1))
% end

% i = 241;
% for j = 241 : 1800
%   if isequal(a1(:,i), a2(:,j))
%     j
%   end
% end

% i = 241 : 480;
% j = 1201 : 1440;
% isequal(a1(:,i), a2(:,j))

% NGAS time is not monotonic
% plot(PacketDataArray.PacketHeader.Time)

% MIT is monotonic but in different units?
% plot(d1.packet.LWES.time)

