%
% checkRDR3 -- validate MIT RDR data 
%
% Loops on MIT RDR mat files.  Flags an obs index OK if the times
% are the same for all FOVs, and checks that the FORs also match.
% Compares MIT and NGAS igms for a selected band and FOV.
% 
% There are 4 main secions,
%   1. concatenate ES, IT and SP igms and sorts them together
%   2. keep ES, IT and SP igms separate and sort them separately
%   3. compare results of 1 and 2
%   4. compare the results of 1 vs a selected NGAS band and FOV
% 
% 2 and 3 are not showing any errors and are probably not needed
% 
% In 4, the MIT times are searched for in the NGAS time sequence.
% Due to sometimes dropping obs with mismatched times, the MIT time
% sequence will be a subset of the NGAS sequence
% 
% derived from testNGAS5.m and related procedures.
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
% Many of the MIT arrays, including time, igm data, FOR flags, and
% ICT parameters, are padded with zeros past the actual end point.
%
% Individual FOV times in the MIT data are sometimes scrambled up.
% For now those records are just skipped.
%
% NGAS data combines ES, IT, and SP igm's in one array
%
% NGAS PacketDataArray.ScanInfo.FOR cycles thru [0,0,1:30,31,31] and
% may start anywhere in the cycle.  PacketDataArray.ScanInfo.SweepDir
% alternates 0, 2
%
% index 43, file d20100906_t0722029 has duplicate time values in both
% the NGAS and MIT data, however the data and FOR values are different

% t_mit * mwt = t_ngas
mwt = 8.64e7;

% original RDR H5 data directory
dsrc  = '/asl/data/cris/Proxy/2010/09/06';

% MIT matlab RDR data directory
dmit = '/asl/data/cris/mott/2010/09/06mit';
lmit = dir(sprintf('%s/RDR*.mat', dmit));

% NGAS matlab RDR data directory
dngs = '/asl/data/cris/mott/2010/09/06';

% NGAS matlab filename and fov index for tests
bngs = 'IGMB1F1Packet_000.mat';
nfov = 1;

% -------------------------
% loop on MIT RDR mat files
% -------------------------

% j = input('file index >');
% for fi = j

for fi = 1 : length(lmit)

  % --------------------------
  % load and validate MIT data
  % --------------------------

  % MIT matlab RDR data file
  rid = lmit(fi).name(5:22);
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

  % sanity check for some good values remaining
  if isempty(ESok) && isempty(ITok) && isempty(SPok)
    fprintf(1, 'FOV times bad for all obs, index %d file %s\n', ...
            fi, rid);
    continue
  end

  % sanity check that FOR agrees for all FOVs
  tmp1 = [ d1.FOR.LWES(1, ESok), ...
           d1.FOR.LWIT(1, ITok), ...
           d1.FOR.LWSP(1, SPok)]';
  for i = 2 : 9
    tmp2 = [ d1.FOR.LWES(i, ESok), ...
             d1.FOR.LWIT(i, ITok), ...
             d1.FOR.LWSP(i, SPok)]';
    if ~isequal(tmp1, tmp2)
       fprintf(1, 'FOV FORs differ, FOV %d index %d file %s\n', i, fi, rid);
       continue
    end
  end

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
  igmLWES = d1.idata.LWES(1:866, :, ESok) + ...
            sqrt(-1) * d1.qdata.LWES(1:866, :, ESok);
  igmMWES = d1.idata.MWES(1:530, :, ESok) + ...
            sqrt(-1) * d1.qdata.MWES(1:530, :, ESok);
  igmSWES = d1.idata.SWES(1:202, :, ESok) + ...
            sqrt(-1) * d1.qdata.SWES(1:202, :, ESok);

  EStime = d1.packet.LWES.time(ESok, 1);
  [EStime, iES] = sort(EStime);
  igmLWES =   igmLWES(:,:,iES);
  igmMWES =   igmMWES(:,:,iES);
  igmSWES =   igmSWES(:,:,iES);

  % subset and sort IT data
  igmLWIT = d1.idata.LWIT(1:866, :, ITok) + ...
            sqrt(-1) * d1.qdata.LWIT(1:866, :, ITok);
  igmMWIT = d1.idata.MWIT(1:530, :, ITok) + ...
            sqrt(-1) * d1.qdata.MWIT(1:530, :, ITok);
  igmSWIT = d1.idata.SWIT(1:202, :, ITok) + ...
            sqrt(-1) * d1.qdata.SWIT(1:202, :, ITok);

  ITtime = d1.packet.LWIT.time(ITok, 1);
  [ITtime, iIT] = sort(ITtime);
  igmLWIT =   igmLWIT(:,:,iIT);
  igmMWIT =   igmMWIT(:,:,iIT);
  igmSWIT =   igmSWIT(:,:,iIT);

  % subset and sort SP data
  igmLWSP = d1.idata.LWSP(1:866, :, SPok) + ...
            sqrt(-1) * d1.qdata.LWSP(1:866, :, SPok);
  igmMWSP = d1.idata.MWSP(1:530, :, SPok) + ...
            sqrt(-1) * d1.qdata.MWSP(1:530, :, SPok);
  igmSWSP = d1.idata.SWSP(1:202, :, SPok) + ...
            sqrt(-1) * d1.qdata.SWSP(1:202, :, SPok);

  SPtime = d1.packet.LWSP.time(SPok, 1);
  [SPtime, iSP] = sort(SPtime);
  igmLWSP =   igmLWSP(:,:,iSP);
  igmMWSP =   igmMWSP(:,:,iSP);
  igmSWSP =   igmSWSP(:,:,iSP);

  % --------------------------------------
  % compare separate and concatenated data
  % --------------------------------------

  % valid FOR data from separate ES, IT, and SP FOR fields
  ESFOR = d1.FOR.LWES(1, ESok)';
  ITFOR = d1.FOR.LWIT(1, ITok)';
  SPFOR = d1.FOR.LWSP(1, SPok)';

  % sorted FOR data from separate ES, IT, and SP FOR fields
  ESFOR = ESFOR(iES);
  ITFOR = ITFOR(iIT);
  SPFOR = SPFOR(iSP);

  % ES, IT, and SP indices into sorted combined igm data
  % (note: we need these for working with the combined data)
  i2ES = (1 <= igmFOR) & (igmFOR <= 30);
  i2IT = igmFOR == 0;
  i2SP = igmFOR == 31;

  % check equivalence of time, FOR, and igm data
  eqflags = ...
  [ isequal(EStime, igmTime(i2ES)), ...
    isequal(ITtime, igmTime(i2IT)), ...
    isequal(SPtime, igmTime(i2SP)), ...
    isequal(ESFOR, igmFOR(i2ES)), ...
    isequal(ITFOR, igmFOR(i2IT)), ...
    isequal(SPFOR, igmFOR(i2SP)), ...
    isequal(igmLWES, igmLW(:,:,i2ES)), ...
    isequal(igmMWES, igmMW(:,:,i2ES)), ...
    isequal(igmSWES, igmSW(:,:,i2ES)), ...
    isequal(igmLWIT, igmLW(:,:,i2IT)), ...
    isequal(igmMWIT, igmMW(:,:,i2IT)), ...
    isequal(igmSWIT, igmSW(:,:,i2IT)), ...
    isequal(igmLWSP, igmLW(:,:,i2SP)), ...
    isequal(igmMWSP, igmMW(:,:,i2SP)), ...
    isequal(igmSWSP, igmSW(:,:,i2SP))];

  if min(eqflags) == 0
    fprintf(1, 'MIT validation failed, index %d file %s , flags:\n', ...
            fi, rid)
    eqflags
  end

  % ---------------
  % NGAS validation
  % ---------------

  % NGAS matlab RDR data file
  rngs = ['RMAT_', rid];
  fngs = [dngs, '/', rngs, '/', bngs];

  % skip test if no NGAS files
  if ~exist(fngs, 'file')
    fprintf(1, 'NGAS files missing, index %d file %s\n', fi, rid)
    continue
  end

  % load the NGAS data, defines structure PacketDataArray
  load(fngs)

  % sort NGAS igm data by time
  [ngTime, ngind] = sort(PacketDataArray.PacketHeader.Time(:));
  ngIGM = PacketDataArray.IGM(:,ngind);

  % scale MIT time to NGAS IET time and add a small stretch term
  % (about 1/200 of a FOR time step) so interp1 always works
  ttmp = igmTime * mwt;
  kk = length(ttmp);
  ttmp(1) = ttmp(1) + 1;
  ttmp(kk) = ttmp(kk) - 1;

  % check for duplicate NGAS or MIT time values
  if min(diff(ttmp)) < 2 || min(diff(ngTime)) < 2
    fprintf(1, 'WARNING: duplicate times index %d file %s\n', fi, rid);
    find(diff(ttmp) < 2)
    find(diff(ngTime) < 2)
  else
    % match NGAS and MIT time indices and compare data
    ix = interp1(ngTime, 1:length(ngTime), ttmp, 'nearest');
    if ~isequal(squeeze(igmLW(:,nfov,:)), ngIGM(:,ix))
      fprintf(1, 'NGAS equality test failed, index %d file %s\n', fi, rid);
    end
  end

end

