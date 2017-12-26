%
% RDR_to_L1a - take NOAA RDR and Geo to ccast L1a
%
% SYNOPSIS
%   RDR_to_L1a(rlist, glist, L1a_dir, opts)
%
% INPUTS
%   rlist    - NOAA RCRIS RDR file list, malab dir format
%   glist    - NOAA GCRSO geo file list, malab dir format
%   L1a_dir  - directory for the L1a output files
%   opts     - options struct
%
% opts fields
%   scans/file
%   
% OUTPUT
%   ccast L1a (with Geo) mat files
%
% DISCUSSION
%   RDR_to_L1a matches RDR and Geo obs (ES, SP, and IT FORs) with
%   time slots in a regular L1b framework, taking into account the
%   CrIS scan timing.  The L1a start time and scans/granule are
%   parameters
%
%   The L1a variables are scLW, scMW, scSW, scTime, scGeo, and
%   scMatch.  "SC" is for scan-order, and as a group these are
%   sometimes called the SC buffer.  The names were chosen for
%   backwards compatibility with the calibration and other ccast
%   functions
%
% AUTHOR
%  H. Motteler, 24 Nov 2017
%

%------------
% test setup
%------------

% function RDR_to_L1a(rdir, gdir, cdir, opts);
function RDR_to_L1a

addpath ../source
addpath ../davet
addpath ../motmsc/time
addpath ../readers/MITreader380b
addpath ../readers/MITreader380b/CrIS

% scans per file
nscanRDR = 60;  % used for initial file selection
nscanGeo = 60;  % used for initial file selection
nscanSC = 45;   % used to define the SC output format

% get a list of GCRSO geo files
gdir = '/asl/data/cris/sdr60/2017/224';

glist = dir2list(gdir, 'GCRSO', nscanGeo);
  glist = glist(2:5);  % TEST TEST TEST

% get a list of RCRIS RDR files
rdir = '/asl/data/cris/rdr60/2017/224';
rlist = dir2list(rdir, 'RCRIS', nscanRDR);
  rlist = rlist(1:4);  % TEST TEST TEST

% L1a output files
L1a_dir = './L1a_2017_224';

% NOAA-style CrIS version
% cvers = 'npp';
  cvers = 'j01';

% git hashtag; replace with function call
gitID = 'c0a1bce';

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
unix(['mkdir -p ', L1a_dir]);

% initial sci and eng data
sci = struct([]);
eng = struct;

%-------------------------------
% Geo and RDR read buffer setup
%-------------------------------
% geo read setup
Gbp = 0;     % Geo buffer pointer
Gfp = 0;     % Geo file pointer
gcount = 0;  % count next_Gbp calls
[geo, geoTime, geoTimeOK, Gfp] = nextGeo(glist, Gfp);
if isempty(geoTime)
  fprintf(1, 'RDR_to_L1a: no valid Geo values on initial read\n')
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
  sci2, eng, igmTimeOK, Rfp] = nextRDR(rlist, ctmp, eng, Rfp);
if isempty(igmTime)
  fprintf(1, 'RDR_to_L1a: no valid RDR values on initial read\n')
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
  ix = find(igmFOR == 1, 1);
  scT0 = igmTime(ix);
% scT0 = geoTime(1);
scTime = fakeTime(scT0, nscanSC, Sfp, 0);
nobsSC = length(scTime);
scTimeOK = false(nobsSC, 1);
scMatch = false(nobsSC, 1);
scLW = []; 
scMW = []; 
scSW = [];
scGeo = struct;
init_SC

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
    fprintf(1, 'RDR_to_L1a: unexpected Geo-RDR time difference\n');
    next_Gbp       % get next Geo pointer
    next_Rbp       % get next RDR pointer

  elseif tg > tr,  % if Geo is ahead of RDR
    next_Rbp;      % get next RDR pointer

  elseif tr > tg,  % if RDR is ahead of Geo
    next_Gbp;      % get next Geo pointer

  else, error('cosmic meltdown'), end
  nloop = nloop + 1;
end

% write out any remaining data
close_SC

fprintf(1, 'nloop = %d\n', nloop)
fprintf(1, 'nmatch = %d\n', nmatch)
fprintf(1, 'ncopy  = %d\n', ncopy)
fprintf(1, 'scount - nskip = %d\n', scount - nskip)
fprintf(1, 'gcount - 1 = %d\n', gcount - 1);
fprintf(1, 'rcount - 1 = %d\n', rcount - 1);
if ~isequal(scTimeOK, scMatch), fprintf(1, 'scTimeOK != scMatch\n'), end

%---------------------------
% SC write buffer functions
%---------------------------

% next_Sbp - called after writing to the SC buffer at obs index Sbp;
% increments Sbp and writes and resets the SC buffer when Sbc wraps.
%
function next_Sbp
  Sbp = Sbp + 1;
  if Sbp > nobsSC
    Sbp = 1;
%   datestr(iet2dnum(scTime(1)))

    % remove sci from the head of the sci2 list
    ix = tai2iet(utc2tai([sci2.time]/1000)) < ts + 4e6;
    sci = sci2(ix);   % sci2 before the SC buffer end + 4 sec
    sci2 = sci2(~ix); % sci2 after the SC buffer end + 4 sec

    % write and reset the SC buffer
    fprintf(1, 'writing L1a file %d, %d values\n', Sfp, nobsSC)
    write_SC;
    init_SC;

    % set up scTime for the next buffer
    Sfp = Sfp + 1;
    scTime = fakeTime(scT0, nscanSC, Sfp, 0);
    scTimeOK = false(nobsSC, 1);
    scMatch = false(nobsSC, 1);
  end
  scount = scount + 1;
end

% close_SC - called after the last SC buffer write.  If there is any
% data left in the SC buffer it writes a final L1a file
%
function close_SC
  if Sbp > 1
%   datestr(iet2dnum(scTime(1)))
    fprintf(1, 'writing L1a file %d, %d values\n', Sfp, Sbp - 1)
    write_SC
  end
end

% write_SC - build an L1a filename and write the SC buffer
%
function write_SC
  dvec = datevec(iet2dnum(scTime(1)));
  dvec(6) = round(dvec(6) * 10);
  stmp = sprintf('CrIS_L1a_%s_s%02d_d%04d%02d%02d_t%02d%02d%03d_%s', ...
    cvers, nscanSC, dvec, gitID);
  save(fullfile(L1a_dir, stmp), ...
    'scLW', 'scMW', 'scSW', 'scTime', 'scGeo', 'scMatch', 'sci', 'eng')
end

% init_SC - initialize the SC igm and Geo buffers
%
function init_SC
  % set the SC igm buffers to undefined
  scLW = NaN(nchanLW, 9, 34, nscanSC);
  scMW = NaN(nchanMW, 9, 34, nscanSC);
  scSW = NaN(nchanSW, 9, 34, nscanSC);

  % set the SC geo buffer to undefined
  scGeo.FORTime               = NaN(30,nscanSC);
  scGeo.Height                = NaN(9,30,nscanSC);
  scGeo.Latitude              = NaN(9,30,nscanSC);
  scGeo.Longitude             = NaN(9,30,nscanSC);
  scGeo.MidTime               = NaN(nscanSC);
  scGeo.PadByte1              = NaN(nscanSC);
  scGeo.QF1_CRISSDRGEO        = NaN(nscanSC);
  scGeo.SatelliteAzimuthAngle = NaN(9,30,nscanSC);
  scGeo.SatelliteRange        = NaN(9,30,nscanSC);
  scGeo.SatelliteZenithAngle  = NaN(9,30,nscanSC);
  scGeo.SolarAzimuthAngle     = NaN(9,30,nscanSC);
  scGeo.SolarZenithAngle      = NaN(9,30,nscanSC);
  scGeo.StartTime             = NaN(nscanSC);
end

% copy2sc - copies RDR ES, SP, and IT igm obs at Rbp and 
% Geo ES obs at Gbp to the SC buffesr at Sbp
%
function copy2sc
  scMatch(Sbp) = true;
  scTimeOK(Sbp) = igmTimeOK(Rbp) & geoTimeOK(Gbp);

  Sbr = mod(Sbp - 1, 34) + 1;      % SC data row index
  Sbc = floor((Sbp - 1) / 34) + 1; % SC data col index

  % FOR index sanity checks
  jFOR = igmFOR(Rbp);
  if 1 <= jFOR && jFOR <= 30
    if jFOR ~= Sbr, error('FOR ES mismatch'), end
  elseif jFOR == 31
    if Sbr ~= 31 && Sbr ~= 32, error('FOR SP mismatch'), end
  elseif jFOR == 0
    if Sbr ~= 33 && Sbr ~= 34, error('FOR IT mismatch'), end
  end

  % sweep direction sanity checks; note IT and SP flip vs ES
  if (1 <= Sbr && Sbr <= 30 && mod(Sbr-1, 2) ~= igmSD(Rbp)) || ...
     (31 <= Sbr && Sbr <= 34 && mod(Sbr, 2) ~= igmSD(Rbp))
    error('bad sweep direction\n')
  end

  % copy RDR igm data to the SC buffer
  scLW(:, :, Sbr, Sbc) = igmLW(:, :, Rbp);
  scMW(:, :, Sbr, Sbc) = igmMW(:, :, Rbp);
  scSW(:, :, Sbr, Sbc) = igmSW(:, :, Rbp);

  % copy Geo ES data to the SC buffer
  Gbr = mod(Gbp - 1, 34) + 1;      % Geo data row index
  Gbc = floor((Gbp - 1) / 34) + 1; % Geo data col index
  if Gbr ~= Sbr
    error('Geo/SC row index mismatch')
  end
  if 1 <= Gbr && Gbr <= 30  % test for ES obs
    scGeo.FORTime(Sbr,Sbc)                 = geo.FORTime(Gbr,Gbc);
    scGeo.Height(:,Sbr,Sbc)                = geo.Height(:,Gbr,Gbc);
    scGeo.Latitude(:,Sbr,Sbc)              = geo.Latitude(:,Gbr,Gbc);
    scGeo.Longitude(:,Sbr,Sbc)             = geo.Longitude(:,Gbr,Gbc);
    scGeo.MidTime(Sbc)                     = geo.MidTime(Gbc);
    scGeo.PadByte1(Sbc)                    = geo.PadByte1(Gbc);
    scGeo.QF1_CRISSDRGEO(Sbc)              = geo.QF1_CRISSDRGEO(Gbc);
    scGeo.SatelliteAzimuthAngle(:,Sbr,Sbc) = geo.SatelliteAzimuthAngle(:,Gbr,Gbc);
    scGeo.SatelliteRange(:,Sbr,Sbc)        = geo.SatelliteRange(:,Gbr,Gbc);
    scGeo.SatelliteZenithAngle(:,Sbr,Sbc)  = geo.SatelliteZenithAngle(:,Gbr,Gbc);
    scGeo.SolarAzimuthAngle(:,Sbr,Sbc)     = geo.SolarAzimuthAngle(:,Gbr,Gbc);
    scGeo.SolarZenithAngle(:,Sbr,Sbc)      = geo.SolarZenithAngle(:,Gbr,Gbc);
    scGeo.StartTime(Sbc)                   = geo.StartTime(Gbc);
  end
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
      sci1, eng, igmTimeOK, Rfp] = nextRDR(rlist, ctmp, eng, Rfp);
    if isempty(igmTime)
      Rbp = 0; 
    else 
      Rbp = 1; 
      nobsRDR = length(igmTime);
      sci2 = [sci2, sci1];  % add sci1 at the tail of sci2
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
