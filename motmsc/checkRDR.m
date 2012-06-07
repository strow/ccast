%
% checkRDR -- validate MIT RDR data 
%
% Loops on MIT RDR mat files.  Merges all 81 timelines (9 fovs x 3
% bands x 3 obs types) to a single sorted list of unique times, does
% some QC on this list, and fits all obs to the merged timeline.
% Compares MIT and NGAS igms for a selected band and FOV.
%
% derived from checkRDR3 and testNGAS4
% 
% To do:
%   check cases where time diff is too small, files 43 and 76
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
% dsrc  = '/asl/data/cris/Proxy/2010/09/06';
dsrc  = '/asl/data/cris/rdr_proxy/hdf/2010/249';

% MIT matlab RDR data directory
% dmit = '/asl/data/cris/rdr_proxy/mat/2010/249v2';
dmit = '/asl/data/cris/rdr_proxy/mat/2010/249';
lmit = dir(sprintf('%s/RDR*.mat', dmit));

% NGAS matlab RDR data directory
% dngs = '/asl/data/cris/rdr_proxy/ng/2010/249v2';
dngs = '/asl/data/cris/rdr_proxy/ng/2010/249';

% NGAS matlab filename and fov index for tests
bngs = 'IGMB1F9Packet_000.mat';
nfov = 9;

% -------------------------
% loop on MIT RDR mat files
% -------------------------

% j = input('file index >');
% for ri = j

% for ri = 1 : 135
for ri = 1 : length(lmit)

% for ri = [9, 35, 38]

% rid = 'd20100906_t0722029';
% rid = 'd20100906_t1705597';  % Dave's file

  % -----------------
  % load the MIT data
  % -----------------

  % MIT matlab RDR data file
  rid = lmit(ri).name(5:22);
  rmit = ['RDR_', rid, '.mat'];
  fmit = [dmit, '/', rmit];

  % skip dir if no MIT file
  if ~exist(fmit, 'file')
    fprintf(1, 'WARNING: MIT file missing, index %d file %s\n', ri, rid)
    continue
  end

  % load the MIT data, defines structures d1 and m1
  load(fmit)

  % ---------------------
  % get a common timeline
  % ---------------------

  % sort and merge all 81 timelines (9 fovs x 3 bands x 3 obs types)
  t1 = unique(mwt * d1.packet.LWES.time(:));
  t2 = unique(mwt * d1.packet.LWIT.time(:));
  t3 = unique(mwt * d1.packet.LWSP.time(:));
  t4 = unique(mwt * d1.packet.MWES.time(:));
  t5 = unique(mwt * d1.packet.MWIT.time(:));
  t6 = unique(mwt * d1.packet.MWSP.time(:));
  t7 = unique(mwt * d1.packet.SWES.time(:));
  t8 = unique(mwt * d1.packet.SWIT.time(:));
  t9 = unique(mwt * d1.packet.SWSP.time(:));
  t0 = unique([t1;t2;t3;t4;t5;t6;t7;t8;t9]);

  % check for valid timeline
  if isempty(t0)
    fprintf(1, 'WARNING: no valid time values, index %d file %s\n', ...
            ri, rid);
    continue
  end

  % drop an initial zero, if present (from zeros in the array tails)
  if t0(1) == 0
    t0 = t0(2:length(t0));
  end

  % check that the min and max time steps are sensible.  10 ms is 5
  % pct of a 200 ms ES FOR step.  A time step of less than 190 ms is
  % probably an error.  If it'is less than 10 ms, the two steps are
  % probably equal so just drop the second.

  dt0 = diff(t0);
  dmin = min(dt0);
  if dmin < 190
    fprintf(1, 'WARNING: time step %.1f too small, index %d file %s\n', ...
            dmin, ri, rid);
%   if dmin < 10
%     % drop the second time value for pairs within 10 ms
%     t0 = t0([1>0; dt0 >= 10]);
%     fprintf(1, 'WARNING: dropping small time step, index %d file %s\n', ...
%             ri, rid);
%   end
  end

  dmax = max(dt0);
  if dmax > 8000
    % looks like we lost at least on scan
    fprintf(1, 'WARNING: time step %.0f too big, index %d file %s\n', ...
            dmax, ri, rid);
  end

  % save the results
  igmTime = t0;
  nobs = length(igmTime);

  % ---------------------------
  % move data to a regular grid
  % ---------------------------

  % get sizes for output arrays
  [n1, m, k] = size(d1.idata.LWES);
  [n2, m, k] = size(d1.idata.MWES);
  [n3, m, k] = size(d1.idata.SWES);

  % initialize output arrays to NaNs
  igmLW = ones(n1, 9, nobs) * NaN;
  igmMW = ones(n2, 9, nobs) * NaN;
  igmsW = ones(n3, 9, nobs) * NaN;

  tmp1FOR = ones(9, nobs) * NaN;
  tmp2FOR = ones(9, nobs) * NaN;
  tmp3FOR = ones(9, nobs) * NaN;
  igmFOR = ones(nobs, 1) * NaN;

  tmp1SDR = ones(9, nobs) * NaN;
  tmp2SDR = ones(9, nobs) * NaN;
  tmp3SDR = ones(9, nobs) * NaN;
  igmSDR = ones(nobs, 1) * NaN;

  % loop on FOVs, merge ES, IT, and SP data
  for i = 1 : 9

    % --------------------------------
    % merge band 1 ES, IT, and SP data
    % --------------------------------
    n = ztail(d1.packet.LWES.time(:, i));
    t1 = d1.packet.LWES.time(1:n, i) * mwt;
    ix = interp1(igmTime, 1:nobs, t1, 'nearest');
    tmp1FOR(i, ix) = d1.FOR.LWES(i, 1:n);
    tmp1SDR(i, ix) = d1.sweep_dir.LWES(i, 1:n);
    igmLW(:, i, ix) =  d1.idata.LWES(:, i, 1:n) + ...
            sqrt(-1) * d1.qdata.LWES(:, i, 1:n);

    n = ztail(d1.packet.LWIT.time(:, i));
    t1 = d1.packet.LWIT.time(1:n, i) * mwt;
    ix = interp1(igmTime, 1:nobs, t1, 'nearest');
    tmp1FOR(i, ix) = d1.FOR.LWIT(i, 1:n);
    tmp1SDR(i, ix) = d1.sweep_dir.LWIT(i, 1:n);
    igmLW(:, i, ix) =  d1.idata.LWIT(:, i, 1:n) + ...
            sqrt(-1) * d1.qdata.LWIT(:, i, 1:n);

    n = ztail(d1.packet.LWSP.time(:, i));
    t1 = d1.packet.LWSP.time(1:n, i) * mwt;
    ix = interp1(igmTime, 1:nobs, t1, 'nearest');
    tmp1FOR(i, ix) = d1.FOR.LWSP(i, 1:n);
    tmp1SDR(i, ix) = d1.sweep_dir.LWSP(i, 1:n);
    igmLW(:, i, ix) =  d1.idata.LWSP(:, i, 1:n) + ...
            sqrt(-1) * d1.qdata.LWSP(:, i, 1:n);

    % --------------------------------
    % merge band 2 ES, IT, and SP data
    % --------------------------------
    n = ztail(d1.packet.MWES.time(:, i));
    t1 = d1.packet.MWES.time(1:n, i) * mwt;
    ix = interp1(igmTime, 1:nobs, t1, 'nearest');
    tmp2FOR(i, ix) = d1.FOR.MWES(i, 1:n);
    tmp2SDR(i, ix) = d1.sweep_dir.MWES(i, 1:n);
    igmMW(:, i, ix) =  d1.idata.MWES(:, i, 1:n) + ...
            sqrt(-1) * d1.qdata.MWES(:, i, 1:n);

    n = ztail(d1.packet.MWIT.time(:, i));
    t1 = d1.packet.MWIT.time(1:n, i) * mwt;
    ix = interp1(igmTime, 1:nobs, t1, 'nearest');
    tmp2FOR(i, ix) = d1.FOR.MWIT(i, 1:n);
    tmp2SDR(i, ix) = d1.sweep_dir.MWIT(i, 1:n);
    igmMW(:, i, ix) =  d1.idata.MWIT(:, i, 1:n) + ...
            sqrt(-1) * d1.qdata.MWIT(:, i, 1:n);

    n = ztail(d1.packet.MWSP.time(:, i));
    t1 = d1.packet.MWSP.time(1:n, i) * mwt;
    ix = interp1(igmTime, 1:nobs, t1, 'nearest');
    tmp2FOR(i, ix) = d1.FOR.MWSP(i, 1:n);
    tmp2SDR(i, ix) = d1.sweep_dir.MWSP(i, 1:n);
    igmMW(:, i, ix) =  d1.idata.MWSP(:, i, 1:n) + ...
            sqrt(-1) * d1.qdata.MWSP(:, i, 1:n);

    % --------------------------------
    % merge band 3 ES, IT, and SP data
    % --------------------------------
    n = ztail(d1.packet.SWES.time(:, i));
    t1 = d1.packet.SWES.time(1:n, i) * mwt;
    ix = interp1(igmTime, 1:nobs, t1, 'nearest');
    tmp3FOR(i, ix) = d1.FOR.SWES(i, 1:n);
    tmp3SDR(i, ix) = d1.sweep_dir.SWES(i, 1:n);
    igmSW(:, i, ix) =  d1.idata.SWES(:, i, 1:n) + ...
            sqrt(-1) * d1.qdata.SWES(:, i, 1:n);

    n = ztail(d1.packet.SWIT.time(:, i));
    t1 = d1.packet.SWIT.time(1:n, i) * mwt;
    ix = interp1(igmTime, 1:nobs, t1, 'nearest');
    tmp3FOR(i, ix) = d1.FOR.SWIT(i, 1:n);
    tmp3SDR(i, ix) = d1.sweep_dir.SWIT(i, 1:n);
    igmSW(:, i, ix) =  d1.idata.SWIT(:, i, 1:n) + ...
            sqrt(-1) * d1.qdata.SWIT(:, i, 1:n);

    n = ztail(d1.packet.SWSP.time(:, i));
    t1 = d1.packet.SWSP.time(1:n, i) * mwt;
    ix = interp1(igmTime, 1:nobs, t1, 'nearest');
    tmp3FOR(i, ix) = d1.FOR.SWSP(i, 1:n);
    tmp3SDR(i, ix) = d1.sweep_dir.SWSP(i, 1:n);
    igmSW(:, i, ix) =  d1.idata.SWSP(:, i, 1:n) + ...
            sqrt(-1) * d1.qdata.SWSP(:, i, 1:n);

  end % loop on FOVs

  % ---------------------------------
  % check that FOR agrees for all FOVs
  % ---------------------------------

  % combine FOR lists for all 3 bands
  t1 = max([tmp1FOR; tmp2FOR; tmp3FOR]);
  t2 = min([tmp1FOR; tmp2FOR; tmp3FOR]);
  igmFOR = t1;  
  t1(isnan(t1)) = -1;
  t2(isnan(t2)) = -1;
  if ~isequal(t1,t2)
     fprintf(1, 'WARNING: FOV FORs differ, index %d file %s\n', ri, rid);
  end

  % combine SDR lists for all 3 bands
  t1 = max([tmp1SDR; tmp2SDR; tmp3SDR]);
  t2 = min([tmp1SDR; tmp2SDR; tmp3SDR]);
  igmSDR = t1;
  t1(isnan(t1)) = -1;
  t2(isnan(t2)) = -1;
  if ~isequal(t1,t2)
     fprintf(1, 'WARNING: FOV sweeps differ, index %d file %s\n', ri, rid);
  end

  % ---------------
  % NGAS validation
  % ---------------

  % NGAS matlab RDR data file
  rngs = ['RMAT_', rid];
  fngs = [dngs, '/', rngs, '/', bngs];

  % skip test if no NGAS files
  if ~exist(fngs, 'file')
    fprintf(1, 'WARNING: NGAS file missing, index %d file %s\n', ri, rid)
    continue
  end

  % load the NGAS data, defines structure PacketDataArray
  load(fngs)

  % sort NGAS igm data by time
  [ngTime, ngind] = sort(PacketDataArray.PacketHeader.Time(:));
  ngIGM = PacketDataArray.IGM(:,ngind);
  ngFOR = PacketDataArray.ScanInfo.FOR(ngind);
  ngSDR = PacketDataArray.ScanInfo.SweepDir(ngind);

  % check for duplicate NGAS or MIT time values
  if min(diff(ngTime)) < 10
    fprintf(1, ...
      'WARNING: NGAS time step too small, index %d file %s\n', ri, rid);
%   find(diff(ngTime) < 10)'
%   fprintf(1, 'skipping comparison\n');
    continue
  end

  % Typically ngTime (single FOV time) will be less than or equal to
  % igmTime (the FOV timeline union).  If not, report it.
  if length(ngTime) > length(igmTime)
    fprintf(1, ...
      'WARNING: length(ngTime) > length(igmTime), index %d file %s\n', ...
       ri, rid);
%   fprintf(1, 'skipping comparison\n');
    continue
  end

  % match NGAS and MIT time indices and compare data
  % note that since length(ngTime) <= length(igmTime), 
  % we fit ngTime to igmTime to match the time sequences
  ttmp = ngTime;
  ttmp(1) = ttmp(1) + 10;
  ttmp(end) = ttmp(end) - 10;
  ix = interp1(igmTime, 1:nobs, ttmp, 'nearest');
  if ~isequal(squeeze(igmLW(1:866,nfov,ix)), ngIGM)
    fprintf(1, ...
      'WARNING: NGAS igm equality test failed, index %d file %s\n', ...
       ri, rid);
  end
  if ~isequal(igmFOR(ix), ngFOR)
    fprintf(1, ...
      'WARNING: NGAS FOR check failed, index %d file %s\n', ...
       ri, rid);
  end
  if ~isequal(igmSDR(ix), ngSDR/2)
    fprintf(1, ...
      'WARNING: NGAS SDR check test failed, index %d file %s\n', ...
       ri, rid);
  end

end % loop on files

