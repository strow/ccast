%
% RDR_to_L1a - take NOAA RDR and Geo to ccast L1a files
%
% SYNOPSIS
%   RDR_to_L1a(rlist, glist, Ldir, opts)
%
% INPUTS
%   rlist  - NOAA RCRIS RDR file list, malab dir format
%   glist  - NOAA GCRSO geo file list, malab dir format
%   Ldir   - directory for the L1a output files
%   opts   - options struct
%
% opts fields
%   see defaults, below.  ops.eng needs to be set and should be a
%   valid eng struct, or at least have valid bit trim mask fields.
%   
% OUTPUT
%   ccast L1a (plus Geo) mat files
%
% DISCUSSION
%   RDR_to_L1a matches RDR and Geo obs (ES, SP, and IT FORs) with
%   the times of an L1b granule framework.  The granule frames start
%   with the first full scan (ES 1) of the day and each granule has
%   nscanSC scans.
%
%   The L1a variables are scLW, scMW, scSW, scTime, scGeo, and
%   scMatch.  "SC" is for scan-order, and as a group these are
%   sometimes called the SC buffer.  This is the output buffer for
%   the L1a granules.
%
% AUTHOR
%  H. Motteler, 24 Nov 2017
%

function RDR_to_L1a(rlist, glist, Ldir, opts)

%--------------------
% default parameters
%--------------------

cvers = 'npp';  % for now, 'npp' or 'j01'
cctag = 'xxx';  % ccast version or run tag

% MIT reader ccsds packet temp file
ctmp = sprintf('ccsds_%05d.tmp', randi(99999));

% scans per file
nscanRDR = 60;  % used for initial file selection
nscanGeo = 60;  % used for initial file selection
nscanSC = 45;   % used to define the SC granule format

eng = struct;   % needs to be set in opts

% apply recognized input options
if nargin == 4
  if isfield(opts, 'cvers'), cvers = opts.cvers; end
  if isfield(opts, 'cctag'), cctag = opts.cctag; end
  if isfield(opts, 'ctmp'), ctmp = opts.ctmp; end
  if isfield(opts, 'nscanRDR'), nscanRDR = opts.nscanRDR; end
  if isfield(opts, 'nscanGeo'), nscanGeo = opts.nscanGeo; end
  if isfield(opts, 'nscanSC'), nscanSC = opts.nscanSC; end
  if isfield(opts, 'eng'), eng = opts.eng; end
end

% initial sci array
sci = struct([]);

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
% set up the SC granule framework
Sfp_max = ceil(10800 / nscanSC); % last granule
% scT0 = dnum2iet(datenum('1 jan 2017 12:08:00'));
% scT0 = geoTime(1);
ix = find(igmFOR == 1, 1);
tES1 = igmTime(ix);
[scT0, Sfp] = granule_t0(tES1, nscanSC);
fprintf(1, 'granule 1 FOR 1 time %s\n', datestr(iet2dnum(scT0)));
scTime = fakeTime(scT0, nscanSC, Sfp, 0);
nobsSC = length(scTime);
scTimeOK = false(nobsSC, 1);
scMatch = false(nobsSC, 1);
scLW = []; 
scMW = []; 
scSW = [];
scGeo = struct;
init_SC

% granule counters and flags (reset after writes)
nloop = 0;         % count main loop iterations
nmatch = 0;        % count RDR-Geo time matchups
ncopy = 0;         % count successful calls of copy2sc
copy_err = false;  % true after first copy2sc error

%-------------------------
% loop on RDR and Geo obs
%-------------------------

while ~isempty(geoTime) && ~isempty(igmTime) && Sfp <= Sfp_max

  % next_Gbp and next_Rbp advance their pointers until they are
  % at valid times, so this should never happen:
  if ~geoTimeOK(Gbp), error('invalid Gbp time in matching loop'), end
  if ~igmTimeOK(Rbp), error('invalid Rbp time in matching loop'), end

  tg = geoTime(Gbp);   % current Geo time
  tr = igmTime(Rbp);   % current RDR time
  ts = scTime(Sbp);    % current SC time

  % test for a Geo-RDR match (time diff < 2 ms)
  if abs(tg - tr) < 2e3 
     nmatch = nmatch + 1;   % increment the match count
     while ts < tg - 2e3;   % while SC is behind Geo
       next_Sbp             % increment the SC pointer
       ts = scTime(Sbp);    % get current SC time
     end  
     if abs(ts - tg) < 2e3  % test for an SC-Geo match
       copy2sc              % copy data on a 3-way match
       next_Sbp             % increment the SC pointer
     end

     % at this point either we had a 3-way match or ts > tg + 2e3
     % in either case we want to advance the Geo and Rdr pointers
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

  else, error('cosmic meltdown in matching loop'), end
  nloop = nloop + 1;
end

% write out any remaining data
close_SC

% total call counts
% fprintf(1, 'scount - 1 = %d\n', scount - 1)
% fprintf(1, 'gcount - 1 = %d\n', gcount - 1);
% fprintf(1, 'rcount - 1 = %d\n', rcount - 1);

% matchup sanity check
if ~isequal(scTimeOK, scMatch)
  fprintf(1, 'RDR_to_L1a: warning scTimeOK != scMatch\n')
end

% all done
fprintf(1, 'RDR_to_L1a: all done\n')

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

    % granule stats
    fprintf(1, 'writing L1a file %d, %d values, ', Sfp, nobsSC)
    fprintf(1, 'nloop=%d nmatch=%d ncopy=%d\n', nloop, nmatch, ncopy)
    nloop = 0; nmatch = 0; ncopy = 0; copy_err = false;

    % write and reset the SC buffer
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
    fprintf(1, 'closing L1a file %d, %d values, ', Sfp, Sbp - 1)
    fprintf(1, 'nloop=%d nmatch=%d ncopy=%d\n', nloop, nmatch, ncopy)
    write_SC
  end
end

% write_SC - build an L1a filename and write the SC buffer
%
function write_SC
  dvec = datevec(iet2dnum(scTime(1)));
  dvec(6) = round(dvec(6) * 10);
  sfmt = 'CrIS_L1a_%s_s%02d_d%04d%02d%02d_t%02d%02d%03d_g%03d_v%s';
  stmp = sprintf(sfmt, cvers, nscanSC, dvec, Sfp, cctag);
  save(fullfile(Ldir, stmp), ...
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
  scGeo.FORTime               = double(NaN(30,nscanSC));
  scGeo.Height                = single(NaN(9,30,nscanSC));
  scGeo.Latitude              = single(NaN(9,30,nscanSC));
  scGeo.Longitude             = single(NaN(9,30,nscanSC));
  scGeo.MidTime               = double(NaN(nscanSC,1));
  scGeo.PadByte1              = single(NaN(nscanSC,1));
  scGeo.QF1_CRISSDRGEO        = single(NaN(nscanSC,1));
  scGeo.SatelliteAzimuthAngle = single(NaN(9,30,nscanSC));
  scGeo.SatelliteRange        = single(NaN(9,30,nscanSC));
  scGeo.SatelliteZenithAngle  = single(NaN(9,30,nscanSC));
  scGeo.SolarAzimuthAngle     = single(NaN(9,30,nscanSC));
  scGeo.SolarZenithAngle      = single(NaN(9,30,nscanSC));
  scGeo.StartTime             = double(NaN(nscanSC,1));
  scGeo.Asc_Desc_Flag         = single(NaN(nscanSC,1));
  scGeo.Orbit_Number          = single(NaN(nscanSC,1));
end

% copy2sc - copies RDR ES, SP, and IT igm obs at Rbp and 
% Geo ES obs at Gbp to the SC buffesr at Sbp
%
function copy2sc
  Sbr = mod(Sbp - 1, 34) + 1;       % SC buffer row index
  Sbc = floor((Sbp - 1) / 34) + 1;  % SC buffer col index

  % FOR index sanity checks
  jFOR = igmFOR(Rbp);
  if 1 <= jFOR && jFOR <= 30
    if jFOR ~= Sbr
      if ~copy_err
        fprintf(1, 'copy2sc: FOR ES mismatch, skipping copy\n')
        fprintf(1, '  Rfp=%d Sfp=%d jFOR=%d, Sbr=%d\n', Rfp, Sfp, jFOR, Sbr)
        copy_err = true;
      end     
      return
    end
  elseif jFOR == 31
    if Sbr ~= 31 && Sbr ~= 32
      if ~copy_err
        fprintf(1, 'copy2sc: FOR SP mismatch, skipping copy\n')
        fprintf(1, '  Rfp=%d Sfp=%d jFOR=%d, Sbr=%d\n', Rfp, Sfp, jFOR, Sbr)
        copy_err = true;
      end
      return
    end
  elseif jFOR == 0
    if Sbr ~= 33 && Sbr ~= 34, 
      if ~copy_err
        fprintf(1, 'copy2sc: FOR IT mismatch, skipping copy\n')
        fprintf(1, '  Rfp=%d Sfp=%d jFOR=%d, Sbr=%d\n', Rfp, Sfp, jFOR, Sbr)
        copy_err = true;
      end
      return
    end
  end

  % sweep direction sanity checks; note IT and SP flip vs ES
  if (1 <= Sbr && Sbr <= 30 && mod(Sbr-1, 2) ~= igmSD(Rbp)) || ...
     (31 <= Sbr && Sbr <= 34 && mod(Sbr, 2) ~= igmSD(Rbp))
    if ~copy_err
      fprintf(1, 'copy2sc: bad sweep direction, skipping copy\n')
      fprintf(1, '  Rfp=%d Sfp=%d Rbp=%d Sbr=%d\n', Rfp, Sfp, Rbp, Sbr)
      copy_err = true;
    end
    return
  end

  % copy RDR igm data to the SC buffer
  scLW(:, :, Sbr, Sbc) = igmLW(:, :, Rbp);
  scMW(:, :, Sbr, Sbc) = igmMW(:, :, Rbp);
  scSW(:, :, Sbr, Sbc) = igmSW(:, :, Rbp);

  % copy Geo ES data to the SC buffer
  Gbr = mod(Gbp - 1, 34) + 1;      % Geo data row index
  Gbc = floor((Gbp - 1) / 34) + 1; % Geo data col index
  if Gbr ~= Sbr
    if ~copy_err
      fprintf(1, 'copy2sc: Geo/SC row index mismatch, skipping copy\n')
      fprintf(1, '  Rfp=%d Gfp=%d Sfp=%d ', Rfp, Gfp, Sfp)
      fprintf(1, 'Gbr=%d Sbr=%d nloop=%d nmatch=%d\n', Gbr, Sbr, nloop, nmatch)
      copy_err = true;
    end
  return
  end
  if 1 <= Gbr && Gbr <= 30  % test for ES obs
    scGeo.FORTime(Sbr,Sbc)                 = geo.FORTime(Gbr,Gbc);
    scGeo.Height(:,Sbr,Sbc)                = geo.Height(:,Gbr,Gbc);
    scGeo.Latitude(:,Sbr,Sbc)              = geo.Latitude(:,Gbr,Gbc);
    scGeo.Longitude(:,Sbr,Sbc)             = geo.Longitude(:,Gbr,Gbc);
    scGeo.MidTime(Sbc,1)                   = geo.MidTime(Gbc,1);
    scGeo.PadByte1(Sbc,1)                  = geo.PadByte1(Gbc,1);
    scGeo.QF1_CRISSDRGEO(Sbc)              = geo.QF1_CRISSDRGEO(Gbc,1);
    scGeo.SatelliteAzimuthAngle(:,Sbr,Sbc) = geo.SatelliteAzimuthAngle(:,Gbr,Gbc);
    scGeo.SatelliteRange(:,Sbr,Sbc)        = geo.SatelliteRange(:,Gbr,Gbc);
    scGeo.SatelliteZenithAngle(:,Sbr,Sbc)  = geo.SatelliteZenithAngle(:,Gbr,Gbc);
    scGeo.SolarAzimuthAngle(:,Sbr,Sbc)     = geo.SolarAzimuthAngle(:,Gbr,Gbc);
    scGeo.SolarZenithAngle(:,Sbr,Sbc)      = geo.SolarZenithAngle(:,Gbr,Gbc);
    scGeo.StartTime(Sbc,1)                 = geo.StartTime(Gbc,1);
    scGeo.Asc_Desc_Flag(Sbc,1)             = geo.Asc_Desc_Flag(Gbc,1);
    scGeo.Orbit_Number(Sbc,1)              = geo.Orbit_Number(Gbc,1);
  end

  scMatch(Sbp) = true;
  scTimeOK(Sbp) = igmTimeOK(Rbp) & geoTimeOK(Gbp);
  ncopy = ncopy + 1;
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
      nobsGeo = 0;
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
      nobsRDR = 0;
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

