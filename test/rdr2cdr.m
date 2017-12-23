%
% rdr2cdr - take RCRIS and GCRSO to ccast CDR files
%
% SYNOPSIS
%   rdr2cdr(rlist, glist, sdir, opts)
%
% INPUTS
%   rlist  - NOAA RCRIS RDR file list, malab dir format
%   glist  - NOAA GCRSO geo file list, malab dir format
%   cdir   - directory for CDR (L1a + Geo) output files
%   opts   - options struct
%
% opts fields
%   scans/file
%   
% OUTPUT
%   ccast CDR (L1a + Geo) mat files
%
% DISCUSSION
%   drives match loop from the RDR and Geo files
%
%  CDR/SDR granules can be defined from FOR 1 in the first Geo
%  or RDR files or set to any other desired time, which should 
%  at least intersect with times in the Geo and RDR lists
%
% AUTHOR
%  H. Motteler, 24 Nov 2017
%

%------------
% test setup
%------------

% function rdr2cdr6(rdir, gdir, cdir, opts);
function rdr2cdr6

addpath ../source
addpath ../davet
addpath ../motmsc/time
addpath ../readers/MITreader380b
addpath ../readers/MITreader380b/CrIS

% scans per file
nscanRDR = 60;  % used for initial file selection
nscanGeo = 60;  % used for initial file selection
nscanSC = 60;   % used to define the output format

% get a list of GCRSO geo files
gdir = '/asl/data/cris/sdr60/2017/181';
glist = dir2list(gdir, 'GCRSO', nscanGeo);
% glist = glist(2:4);  % TEST TEST TEST

% get a list of RCRIS RDR files
rdir = '/asl/data/cris/rdr60/2017/181';
rlist = dir2list(rdir, 'RCRIS', nscanRDR);
% rlist = rlist(1:3);  % TEST TEST TEST

cdir = './cdr_181';

% moving average span is 2 * mvspan + 1
% mvspan = opts.mvspan;
mvspan = 4;

btrim = 'btrim_cache.mat';

% get a CCSDS temp filename
jdir = getenv('JOB_SCRATCH_DIR');
pstr = getenv('SLURM_PROCID');
if ~isempty(jdir) && ~isempty(pstr)
  ctmp = fullfile(jdir, sprintf('ccsds_%s.tmp', pstr));
else
  ctmp = sprintf('ccsds_%03d.tmp', randi(9999));
end

% create the output path, if needed
unix(['mkdir -p ', cdir]);

% initial eng packet
eng = struct([]);

%-------------------------------
% Geo and RDR read buffer setup
%-------------------------------
% geo read setup
Gbp = 0;     % Geo buffer pointer
Gfp = 0;     % Geo file pointer
gcount = 0;  % count next_Gbp calls
[geo, geoTime, geoTimeOK, Gfp] = nextGeo(glist, Gfp);
if isempty(geoTime)
  fprintf(1, 'rdr2cdr: no valid Geo values on initial read\n')
  return
end
nobsGeo = length(geoTime);
next_Gbp

% RDR read setup
Rbp = 0;     % RDR buffer pointer
Rfp = 0;     % RDR file pointer
rcount = 0;  % count next_Rbp calls
eng = struct([]);
[igmLW, igmMW, igmSW, igmTime, igmFOR, igmSD, ...
  sci, eng, igmTimeOK, Rfp] = nextRDR(rlist, ctmp, eng, Rfp);
if isempty(igmTime)
  fprintf(1, 'rdr2cdr: no valid RDR values on initial read\n')
  return
end
nobsRDR = length(igmTime);
next_Rbp

% get array sizes from RDR data
[nchanLW, ~, ~] = size(igmLW);
[nchanMW, ~, ~] = size(igmMW);
[nchanSW, ~, ~] = size(igmSW);

%-----------------------
% SC write buffer setup
%-----------------------
Sbp = 1;     % SC buffer pointer
Sfp = 1;     % SC file pointer
scount = 0;  % count next_Sbp calls
% set up scTime for the first buffer
% fakeTime takes initial time, scans/file, file indes, and an
% optional FOR offset and extrapolates obs times by file index
% scT0 = dnum2iet(datenum('1 jan 2017 12:08:00'));
% ix = find(igmFOR == 1, 1);
% scT0 = igmTime(ix);
  scT0 = geoTime(1);
scTime = fakeTime(scT0, nscanSC, Sfp, 0);
nobsSC = length(scTime);
scTimeOK = false(nobsSC, 1);
scMatch = false(nobsSC, 1);

% set SC buffer to undefined
scLW = NaN(nchanLW, 9, 34, nscanSC);
scMW = NaN(nchanMW, 9, 34, nscanSC);
scSW = NaN(nchanSW, 9, 34, nscanSC);

% initialize test counters
nloop = 0;   % count main loop iterations
nmatch = 0;  % count RDR-Geo time matchups
ncopy = 0;   % count RDR and Geo copies to SC
nskip = 0;   % Sbp catchup steps to RDR-Geo match 

%-------------------------
% loop on RDR and Geo obs
%-------------------------
while ~isempty(geoTime) && ~isempty(igmTime)

  tg = geoTime(Gbp);   % current Geo time
  tr = igmTime(Rbp);   % current RDR time
  ts = scTime(Sbp);    % current SC time

  % test for a Geo-RDR match (time diff < 2 ms)
  if abs(tg - tr) < 2e3 
     nmatch = nmatch + 1;   % increment the match count
     while ts < tg - 2e3;   % while SC is behind Geo
       next_Sbp             % increment the SC pointer
       nskip = nskip + 1;   % increment SC skip count
       ts = scTime(Sbp);    % get current SC time
     end  
     if abs(ts - tg) < 2e3  % test for an SC-Geo match
       copy2sc              % copy data on a 3-way match
       ncopy = ncopy + 1;   % increment the copy count
       next_Sbp             % increment the SC pointer
     end
     next_Gbp      % get next Geo pointer
     next_Rbp      % get next RDR pointer

  % test for an unexpected Geo-RDR time difference
  elseif(abs(tg - tr) < 100e3)
    fprintf(1, 'rdr2cdr: unexpected Geo-RDR time difference\n');
    next_Gbp       % get next Geo pointer
    next_Rbp       % get next RDR pointer

  elseif tg > tr,  % if Geo is ahead of RDR
    next_Rbp;      % get next RDR pointer

  elseif tr > tg,  % if RDR is ahead of Geo
    next_Gbp;      % get next Geo pointer

  else, error('cosmic meltdown'), end
  nloop = nloop + 1;
end

close_Sbp

fprintf(1, 'nloop = %d\n', nloop)
fprintf(1, 'nmatch = %d\n', nmatch)
fprintf(1, 'ncopy  = %d\n', ncopy)
fprintf(1, 'scount - nskip = %d\n', scount - nskip)
fprintf(1, 'gcount - 1 = %d\n', gcount - 1);
fprintf(1, 'rcount - 1 = %d\n', rcount - 1);
if ~isequal(scTimeOK, scMatch), fprintf(1, 'scTimeOK != scMatch\n'), end

% keyboard

%---------------------------
% SC write buffer functions
%---------------------------
% next_Sbp is called after writing data to the SC buffer at Sbp.
% next_Sbp increments the buffer pointer Sbp and writes and resets
% the buffer when the pointer wraps.  SC buffer times in scTime are
% set on initialization and updated on the wraps.

function next_Sbp
  Sbp = Sbp + 1;
  if Sbp > nobsSC
    Sbp = 1;
%   datestr(iet2dnum(scTime(1)))
    fprintf(1, 'writing SDR file %d, %d values\n', Sfp, nobsSC)
    save(fullfile(cdir, sprintf('SDR_test_%03d', Sfp)), ...
      'scLW', 'scMW', 'scSW', 'scTime', 'geo', 'sci', 'eng')

    % reset SC buffer to undefined
    scLW = NaN(nchanLW, 9, 34, nscanSC);
    scMW = NaN(nchanMW, 9, 34, nscanSC);
    scSW = NaN(nchanSW, 9, 34, nscanSC);

    % set up scTime for the next buffer
    Sfp = Sfp + 1;
    scTime = fakeTime(scT0, nscanSC, Sfp, 0);
    scTimeOK = false(nobsSC, 1);
    scMatch = false(nobsSC, 1);
  end
  scount = scount + 1;
end

function close_Sbp
  if Sbp > 1
%   datestr(iet2dnum(scTime(1)))
    fprintf(1, 'writing SDR file %d, %d values\n', Sfp, Sbp - 1)
  end
end

function copy2sc
  scMatch(Sbp) = true;
  scTimeOK(Sbp) = igmTimeOK(Rbp) & geoTimeOK(Gbp);

  Sbr = mod(Sbp - 1, 34) + 1;
  Sbc = floor((Sbp - 1) / 34) + 1;

  % FOR index sanity checks
  jFOR = igmFOR(Rbp);
  if 1 <= jFOR && jFOR <= 30
    if jFOR ~= Sbr, error('FOR ES mismatch'), end
  elseif jFOR == 31
    if Sbr ~= 31 && Sbr ~= 32, error('FOR SP mismatch'), end
  elseif jFOR == 0
    if Sbr ~= 33 && Sbr ~= 34, error('FOR IT mismatch'), end
  end

  scLW(:, :, Sbr, Sbc) = igmLW(:, :, Rbp);
  scMW(:, :, Sbr, Sbc) = igmMW(:, :, Rbp);
  scSW(:, :, Sbr, Sbc) = igmSW(:, :, Rbp);
end

%---------------------------
% Geo read buffer functions
%---------------------------
% next_Gbp is called before reading new Geo buffer time or data
% values at Gbp.  next_Gbp increments the buffer pointer to the
% next valid Geo obs and reloads the buffer when the pointer wraps.
% An obs is considered valid if geoTime is non-empty and geoTimeOK 
% is true.

function inc_Gbp
  Gbp = Gbp + 1;
  if Gbp > nobsGeo
    [geo, geoTime, geoTimeOK, Gfp] = nextGeo(glist, Gfp);
    if isempty(geoTime), 
      Gbp = 0; 
    else 
      Gbp = 1; 
      nobsGeo = length(geoTime);
    end
  end
  gcount = gcount + 1;
end 

function next_Gbp
  inc_Gbp;
  while ~isempty(geoTime) && ~geoTimeOK(Gbp)
     inc_Gbp;
  end
end

%---------------------------
% RDR read buffer functions
%---------------------------
% next_Rbp is called before reading new RDR buffer time or data
% values at Rbp.  next_Rbp increments the buffer pointer to the
% next valid RDR obs and reloads the buffer when the pointer wraps.
% An obs is considered valid if igmTime is non-empty and igmTimeOK 
% is true.

function inc_Rbp
  Rbp = Rbp + 1;
  if Rbp > nobsRDR
    [igmLW, igmMW, igmSW, igmTime, igmFOR, igmSD, ...
      sci, eng, igmTimeOK, Rfp] = nextRDR(rlist, ctmp, eng, Rfp);
    nobsRDR = length(igmTime);
    if isempty(igmTime)
      Rbp = 0; 
    else 
      Rbp = 1; 
      nobsRDR = length(igmTime);
    end
  end
  rcount = rcount + 1;
end 

function next_Rbp
  inc_Rbp;
  while ~isempty(igmTime) && ~igmTimeOK(Rbp)
     inc_Rbp;
  end
end

end % main

