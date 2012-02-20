
% validate MIT RDR data
%
% derived from testNGAS5.m and and related procedures.
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

% t_mit * mwt = t_ngas
mwt = 8.64e7;

% original data source for readers
dsrc  = '/asl/data/cris/Proxy/2010/09/06';

% NGAS matlab RDR data directory
dngs = '/asl/data/cris/mott/2010/09/06';
lngs = dir(sprintf('%s/RMAT*', dngs));

% NGAS matlab filename and fov index
bngs = 'IGMB1F1Packet_000.mat';
nfov = 1;

% MIT matlab RDR data directory
dmit = '/asl/data/cris/mott/2010/09/06mit';

% ------------------------
% loop on NGAS directories
% ------------------------
% This is just temporary, while the NGAS checks remain in the code.
% eventually file id string rid should come from the MIT filenames.

for i = 1 : length(lngs)

  % ---------------------------
  % load and sort the NGAS data
  % ---------------------------

  % NGAS matlab RDR data file
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

  % split the NGAS data into ES, IT, and SP sets
  iES = 1 <= PacketDataArray.ScanInfo.FOR & PacketDataArray.ScanInfo.FOR <= 30;
  iIT = PacketDataArray.ScanInfo.FOR == 0;
  iSP = PacketDataArray.ScanInfo.FOR == 31;

  igmES = PacketDataArray.IGM(:,iES); 
  igmIT = PacketDataArray.IGM(:,iIT); 
  igmSP = PacketDataArray.IGM(:,iSP); 

  % put NGAS subsets in time-sorted order
  [tx, ix] = sort(PacketDataArray.PacketHeader.Time(iES));
  ngasES = igmES(:,ix);

  [tx, ix] = sort(PacketDataArray.PacketHeader.Time(iIT));
  ngasIT = igmIT(:,ix); 

  [tx, ix] = sort(PacketDataArray.PacketHeader.Time(iSP));
  ngasSP = igmSP(:,ix);

  % --------------------------
  % load and validate MIT data
  % --------------------------

  % MIT matlab RDR data file
  rmit = ['RDR_', rid, '.mat'];
  fmit = [dmit, '/', rmit];

  % load the MIT data, defines structures d1 and m1
  load(fmit)

  % these should all be the same, but...
  [n1,mx] = size(d1.packet.LWES.time);
  [n2,mx] = size(d1.packet.MWES.time);
  [n3,mx] = size(d1.packet.SWES.time);
  n = min([n1,n2,n3]);

  % select obs indices where all times are the same
  ESok = find(sum(abs(diff([d1.packet.LWES.time(1:n,:)'; ...
                            d1.packet.MWES.time(1:n,:)'; ...
                            d1.packet.SWES.time(1:n,:)']))) == 0);

  % use subset of good data for complex igm's
  LWESigm = d1.idata.LWES(1:866, :, ESok) + ...
            sqrt(-1) * d1.qdata.LWES(1:866, :, ESok);
  MWESigm = d1.idata.MWES(1:530, :, ESok) + ...
            sqrt(-1) * d1.qdata.MWES(1:530, :, ESok);
  SWESigm = d1.idata.SWES(1:202, :, ESok) + ...
            sqrt(-1) * d1.qdata.SWES(1:202, :, ESok);

  % sort the interferogram data by time
  EStime = d1.packet.LWES.time(ESok, 1);
  [EStime, iES] = sort(EStime);
  LWESigm =   LWESigm(:,:,iES);
  MWESigm =   MWESigm(:,:,iES);
  SWESigm =   SWESigm(:,:,iES);

  % get subset of IT data with consistent times
  [n1,mx] = size(d1.packet.LWIT.time);
  [n2,mx] = size(d1.packet.MWIT.time);
  [n3,mx] = size(d1.packet.SWIT.time);
  n = min([n1,n2,n3]);

  ITok = find(sum(abs(diff([d1.packet.LWIT.time(1:n,:)'; ...
                            d1.packet.MWIT.time(1:n,:)'; ...
                            d1.packet.SWIT.time(1:n,:)']))) == 0);

  LWITigm = d1.idata.LWIT(1:866, :, ITok) + ...
            sqrt(-1) * d1.qdata.LWIT(1:866, :, ITok);
  MWITigm = d1.idata.MWIT(1:530, :, ITok) + ...
            sqrt(-1) * d1.qdata.MWIT(1:530, :, ITok);
  SWITigm = d1.idata.SWIT(1:202, :, ITok) + ...
            sqrt(-1) * d1.qdata.SWIT(1:202, :, ITok);

  % sort the IT data
  ITtime = d1.packet.LWIT.time(ITok, 1);
  [ITtime, iIT] = sort(ITtime);
  LWITigm =   LWITigm(:,:,iIT);
  MWITigm =   MWITigm(:,:,iIT);
  SWITigm =   SWITigm(:,:,iIT);

  % get subset of SP data with consistent times
  [n1,mx] = size(d1.packet.LWSP.time);
  [n2,mx] = size(d1.packet.MWSP.time);
  [n3,mx] = size(d1.packet.SWSP.time);
  n = min([n1,n2,n3]);

  SPok = find(sum(abs(diff([d1.packet.LWSP.time(1:n,:)'; ...
                            d1.packet.MWSP.time(1:n,:)'; ...
                            d1.packet.SWSP.time(1:n,:)']))) == 0);

  LWSPigm = d1.idata.LWSP(1:866, :, SPok) + ...
            sqrt(-1) * d1.qdata.LWSP(1:866, :, SPok);
  MWSPigm = d1.idata.MWSP(1:530, :, SPok) + ...
            sqrt(-1) * d1.qdata.MWSP(1:530, :, SPok);
  SWSPigm = d1.idata.SWSP(1:202, :, SPok) + ...
            sqrt(-1) * d1.qdata.SWSP(1:202, :, SPok);

  % sort the SP data
  SPtime = d1.packet.LWSP.time(SPok, 1);
  [SPtime, iSP] = sort(SPtime);
  LWSPigm =   LWSPigm(:,:,iSP);
  MWSPigm =   MWSPigm(:,:,iSP);
  SWSPigm =   SWSPigm(:,:,iSP);

 % *** lots more goes here ***

end

