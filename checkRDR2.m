
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
% The NGAS and MIT FOR numbering has IT=0 and SP=31.  According to
% the Bomem ATBD SP=0 and IT=31, but maybe that's out of date.
%
% PacketDataArray.ScanInfo.FOR cycles thru [0,0,1:30,31,31] and may
% start anywhere.  PacketDataArray.ScanInfo.SweepDir alternates 0, 2
%
% index 42, file d20100906_t0722029 has duplicate time values in both
% the NGAS and MIT data

% t_mit * mwt = t_ngas
mwt = 8.64e7;

% original data source for readers
dsrc  = '/asl/data/cris/Proxy/2010/09/06';

% MIT matlab RDR data directory
dmit = '/asl/data/cris/mott/2010/09/06mit';

% NGAS matlab RDR data directory
dngs = '/asl/data/cris/mott/2010/09/06';
lngs = dir(sprintf('%s/RMAT*', dngs));

% NGAS matlab filename and fov index for tests
bngs = 'IGMB1F1Packet_000.mat';
nfov = 1;

% ------------------------
% loop on NGAS directories
% ------------------------
% This is just temporary, while the NGAS checks remain in the code.
% eventually file id string rid should come from the MIT filenames.

% j = input('file index >');
% for fi = j

for fi = 1 : length(lngs)

  % ---------------------------
  % load and sort the NGAS data
  % ---------------------------

  % NGAS matlab RDR data file
  rid = lngs(fi).name(6:23);
  rngs = ['RMAT_', rid];
  fngs = [dngs, '/', rngs, '/', bngs];

  % skip dir if no NGAS files
  if ~exist(fngs, 'file')
    fprintf(1, 'NGAS files missing, index %d file %s\n', fi, rid)
    continue
  end

  % load the NGAS data, defines structure PacketDataArray
  load(fngs)

% for now, skip the NGAS data split
%
% % split the NGAS data into ES, IT, and SP sets
% iES = 1 <= PacketDataArray.ScanInfo.FOR & PacketDataArray.ScanInfo.FOR <= 30;
% iIT = PacketDataArray.ScanInfo.FOR == 0;
% iSP = PacketDataArray.ScanInfo.FOR == 31;
%
% ngES = PacketDataArray.IGM(:,iES); 
% ngIT = PacketDataArray.IGM(:,iIT); 
% ngSP = PacketDataArray.IGM(:,iSP); 
%
% % put NGAS subsets in time-sorted order
% [tx, ix] = sort(PacketDataArray.PacketHeader.Time(iES));
% ngES = ngES(:,ix);
%
% [tx, ix] = sort(PacketDataArray.PacketHeader.Time(iIT));
% ngIT = ngIT(:,ix); 
%
% [tx, ix] = sort(PacketDataArray.PacketHeader.Time(iSP));
% ngSP = ngSP(:,ix);
%
% clear iES iIT iSP tx ix

  % --------------------------
  % load and validate MIT data
  % --------------------------

  % MIT matlab RDR data file
  rmit = ['RDR_', rid, '.mat'];
  fmit = [dmit, '/', rmit];

  % skip dir if no MIT file
  if ~exist(fmit, 'file')
    fprintf(1, 'MIT file missing, index %d file %s\n', fi, rid)
    continue
  end

  % load the MIT data, defines structures d1 and m1
  load(fmit)

  % obs size should be the same for all bands, but...
  [n1,mx] = size(d1.packet.LWES.time);
  [n2,mx] = size(d1.packet.MWES.time);
  [n3,mx] = size(d1.packet.SWES.time);
  nES = min([n1,n2,n3]);

  [n1,mx] = size(d1.packet.LWIT.time);
  [n2,mx] = size(d1.packet.MWIT.time);
  [n3,mx] = size(d1.packet.SWIT.time);
  nIT = min([n1,n2,n3]);

  [n1,mx] = size(d1.packet.LWSP.time);
  [n2,mx] = size(d1.packet.MWSP.time);
  [n3,mx] = size(d1.packet.SWSP.time);
  nSP = min([n1,n2,n3]);

  % select obs indices where all FOV times are the same
  ESok = find(sum(abs(diff([d1.packet.LWES.time(1:nES,:)'; ...
                            d1.packet.MWES.time(1:nES,:)'; ...
                            d1.packet.SWES.time(1:nES,:)']))) == 0);

  ITok = find(sum(abs(diff([d1.packet.LWIT.time(1:nIT,:)'; ...
                            d1.packet.MWIT.time(1:nIT,:)'; ...
                            d1.packet.SWIT.time(1:nIT,:)']))) == 0);

  SPok = find(sum(abs(diff([d1.packet.LWSP.time(1:nSP,:)'; ...
                            d1.packet.MWSP.time(1:nSP,:)'; ...
                            d1.packet.SWSP.time(1:nSP,:)']))) == 0);

  % --------------------------------
  % concatenate ES, IT, and SP IGM's
  % --------------------------------

  % concatenate and sort ES, IT, and SP time
  igmTime = [ d1.packet.LWES.time(ESok, 1); ...
              d1.packet.LWIT.time(ITok, 1); ...
              d1.packet.LWSP.time(SPok, 1) ];
  [igmTime, tind] = sort(igmTime);

  % concatenate and sort ES, IT, and SP FORs
  igmFOR = [ d1.FOR.LWES(1, ESok), ...
             d1.FOR.LWIT(1, ITok), ...
             d1.FOR.LWSP(1, SPok)]';
  igmFOR = igmFOR(tind);

  % sanity check that FOR agress for all FOVs
  tmp1 = [ d1.FOR.LWES(1, ESok), ...
           d1.FOR.LWIT(1, ITok), ...
           d1.FOR.LWSP(1, SPok)]';
  for i = 2 : 9
    tmp2 = [ d1.FOR.LWES(i, ESok), ...
             d1.FOR.LWIT(i, ITok), ...
             d1.FOR.LWSP(i, SPok)]';
    if ~isequal(tmp1, tmp2)
       fprintf(1, 'FOV FORs differ, FOV %d index %d file %s\n', ...
               i, fi, rid);
       keyboard
    end
  end

  % concatenate ES, IT, and SP igm's
  igmLW = cat(3, d1.idata.LWES(1:866, :, ESok), ...
                 d1.idata.LWIT(1:866, :, ITok), ...
                 d1.idata.LWSP(1:866, :, SPok)) + ...
          cat(3, d1.qdata.LWES(1:866, :, ESok), ...
                 d1.qdata.LWIT(1:866, :, ITok), ...
                 d1.qdata.LWSP(1:866, :, SPok)) * sqrt(-1);

  igmMW = cat(3, d1.idata.MWES(1:530, :, ESok), ...
                 d1.idata.MWIT(1:530, :, ITok), ...
                 d1.idata.MWSP(1:530, :, SPok)) + ...
          cat(3, d1.qdata.MWES(1:530, :, ESok), ...
                 d1.qdata.MWIT(1:530, :, ITok), ...
                 d1.qdata.MWSP(1:530, :, SPok)) * sqrt(-1);

  igmSW = cat(3, d1.idata.SWES(1:202, :, ESok), ...
                 d1.idata.SWIT(1:202, :, ITok), ...
                 d1.idata.SWSP(1:202, :, SPok)) + ...
          cat(3, d1.qdata.SWES(1:202, :, ESok), ...
                 d1.qdata.SWIT(1:202, :, ITok), ...
                 d1.qdata.SWSP(1:202, :, SPok)) * sqrt(-1);

  igmLW = igmLW(:,:,tind);
  igmMW = igmMW(:,:,tind);
  igmSW = igmSW(:,:,tind);

  % -----------------------------------
  % get ES, IT, and SP IGM's separately
  % -----------------------------------

  % subset and sort ES data
  LWESigm = d1.idata.LWES(1:866, :, ESok) + ...
            sqrt(-1) * d1.qdata.LWES(1:866, :, ESok);
  MWESigm = d1.idata.MWES(1:530, :, ESok) + ...
            sqrt(-1) * d1.qdata.MWES(1:530, :, ESok);
  SWESigm = d1.idata.SWES(1:202, :, ESok) + ...
            sqrt(-1) * d1.qdata.SWES(1:202, :, ESok);

  EStime = d1.packet.LWES.time(ESok, 1);
  [EStime, iES] = sort(EStime);
  LWESigm =   LWESigm(:,:,iES);
  MWESigm =   MWESigm(:,:,iES);
  SWESigm =   SWESigm(:,:,iES);

  % subset and sort IT data
  LWITigm = d1.idata.LWIT(1:866, :, ITok) + ...
            sqrt(-1) * d1.qdata.LWIT(1:866, :, ITok);
  MWITigm = d1.idata.MWIT(1:530, :, ITok) + ...
            sqrt(-1) * d1.qdata.MWIT(1:530, :, ITok);
  SWITigm = d1.idata.SWIT(1:202, :, ITok) + ...
            sqrt(-1) * d1.qdata.SWIT(1:202, :, ITok);

  ITtime = d1.packet.LWIT.time(ITok, 1);
  [ITtime, iIT] = sort(ITtime);
  LWITigm =   LWITigm(:,:,iIT);
  MWITigm =   MWITigm(:,:,iIT);
  SWITigm =   SWITigm(:,:,iIT);

  % subset and sort SP data
  LWSPigm = d1.idata.LWSP(1:866, :, SPok) + ...
            sqrt(-1) * d1.qdata.LWSP(1:866, :, SPok);
  MWSPigm = d1.idata.MWSP(1:530, :, SPok) + ...
            sqrt(-1) * d1.qdata.MWSP(1:530, :, SPok);
  SWSPigm = d1.idata.SWSP(1:202, :, SPok) + ...
            sqrt(-1) * d1.qdata.SWSP(1:202, :, SPok);

  SPtime = d1.packet.LWSP.time(SPok, 1);
  [SPtime, iSP] = sort(SPtime);
  LWSPigm =   LWSPigm(:,:,iSP);
  MWSPigm =   MWSPigm(:,:,iSP);
  SWSPigm =   SWSPigm(:,:,iSP);

  % -----------------------
  % MIT internal validation
  % -----------------------

  i2ES = (1 <= igmFOR) & (igmFOR <= 30);
  i2IT = igmFOR == 0;
  i2SP = igmFOR == 31;

  ESFOR = d1.FOR.LWES(1, ESok)';
  ITFOR = d1.FOR.LWIT(1, ITok)';
  SPFOR = d1.FOR.LWSP(1, SPok)';

  ESFOR = ESFOR(iES);
  ITFOR = ITFOR(iIT);
  SPFOR = SPFOR(iSP);

  eqflags = ...
  [ isequal(EStime, igmTime(i2ES)), ...
    isequal(ITtime, igmTime(i2IT)), ...
    isequal(SPtime, igmTime(i2SP)), ...
    isequal(ESFOR, igmFOR(i2ES)), ...
    isequal(ITFOR, igmFOR(i2IT)), ...
    isequal(SPFOR, igmFOR(i2SP)), ...
    isequal(LWESigm, igmLW(:,:,i2ES)), ...
    isequal(MWESigm, igmMW(:,:,i2ES)), ...
    isequal(SWESigm, igmSW(:,:,i2ES)), ...
    isequal(LWITigm, igmLW(:,:,i2IT)), ...
    isequal(MWITigm, igmMW(:,:,i2IT)), ...
    isequal(SWITigm, igmSW(:,:,i2IT)), ...
    isequal(LWSPigm, igmLW(:,:,i2SP)), ...
    isequal(MWSPigm, igmMW(:,:,i2SP)), ...
    isequal(SWSPigm, igmSW(:,:,i2SP))];

  if min(eqflags) == 0
    fprintf(1, 'equality test failed, index %d file %s , flags:\n', ...
            fi, rid)
    eqflags
  end

  % ---------------
  % NGAS validation
  % ---------------

  % basic check, assumes good MIT data is at the start
  % [mx,nx,k1] = size(LWESigm);
  % [i, isequal(squeeze(LWESigm(:,nfov,1:k1)), ngES(:,1:k1))]

  [ngTime, ngind] = sort(PacketDataArray.PacketHeader.Time(:));

  ngIGM = PacketDataArray.IGM(:,ngind);

  % iobsmin = interp1(vobs, 1:length(vobs), vmin, 'nearest');
  % iobsmax = interp1(vobs, 1:length(vobs), vmax, 'nearest');

  ttmp = igmTime * mwt;
  kk = length(ttmp);
  ttmp(1) = ttmp(1) + 1e-3;
  ttmp(kk) = ttmp(kk) - 1e-3;

  if min(diff(ttmp)) == 0 || min(diff(ngTime)) == 0
    fprintf(1, 'WARNING: duplicate times index %d file %s\n', fi, rid);
    find(diff(ttmp) == 0)
    find(diff(ngTime) == 0)
  else
    ix = interp1(ngTime, 1:length(ngTime), ttmp, 'nearest');
    [fi, isequal(squeeze(igmLW(:,nfov,:)), ngIGM(:,ix))]
  end

  % *** lots more goes here ***

end

