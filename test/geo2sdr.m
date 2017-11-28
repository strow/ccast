%
% NAME
%   geo2sdr - take GCRSO and RCRIS files to ccast SDRs
%
% SYNOPSIS
%   geo2sdr(gdir, rdir, sdir, opts)
%
% INPUTS
%   gdir  - NOAA GCRSO geo files
%   rdir  - NOAA RCRIS RDR files
%   sdir  - SDR output files
%   opts  - options struct
%
% opts fields
%   see recent driver files
%   
% OUTPUT
%   SDR mat files
%
% DISCUSSION
%   drive main processing loop from geo rather than RDR files
%
% AUTHOR
%  H. Motteler, 24 Nov 2017
%

function geo2sdr(gdir, rdir, sdir, opts);

%---------------
% general setup 
%---------------

% create the output path, if needed
unix(['mkdir -p ', sdir]);

% moving average span is 2 * mvspan + 1
mvspan = opts.mvspan;

% initial eng packet
eng = struct([]);

%-----------
% geo setup
%-----------

% get a list of GCRSO geo files
glist = dir(fullfile(gdir, 'GCRSO_npp*.h5'));

% drop anything too small to be a 60-scan file
% n1 = length(glist);
% ix = find([glist.bytes] > 400000);
% glist = glist(ix);
% n2 = length(glist);
% if n2 < n1
%   fprintf(1, 'geo2sdr: %d short file(s)\n', n1 - n2)
% end

if isempty(glist)
  fprintf(1, 'geo2sdr: no GCRSO files in %s\n', gdir)
  return
end

% use the last if there are duplicate RIDs
tlist = {};
for ix = 1 : length(glist)
  tlist{ix} = glist(ix).name(11:28);
end
[~, ix] = unique(tlist);
glist = glist(ix);

%-----------
% RDR setup
%-----------

% get a list of RCRIS RDR files
rlist = dir(fullfile(rdir, 'RCRIS-RNSCA_npp*.h5'));

% drop 4-scan or smaller files
% ix = find([rlist.bytes] > 8e6);
% rlist = rlist(ix);

if isempty(rlist)
  fprintf(1, 'geo2sdr: no RCRIS files in %s\n', rdir)
  return
end

% use the last if there are duplicate RIDs
tlist = {};
for ix = 1 : length(rlist)
  tlist{ix} = rlist(ix).name(17:34);
end
[~, ix] = unique(tlist);
rlist = rlist(ix);

%-------------------
% loop on geo files
%-------------------
fi = 1;
for gi = 1 : length(glist);

  % geo date and start time
  gid = glist(gi).name(11:28);  

  % print a short status message
  fprintf(1, 'geo2sdr: processing index %d file %s\n', gi, gid)

  % read the next geo file
  gfile = fullfile(gdir, glist(gi).name); 
  try 
    geo = read_GCRSO(gfile);
  catch
    fprintf(1, 'geo2sdr: error reading %s\n', gfile)
    fprintf(1, 'continuing with the next file...\n')
    continue
  end

  % get scans in this file
  [m, nscan] = size(geo.FORTime);

  % matlab SDR output file
  stmp = ['SDR_', gid, '.mat'];
  sfile = fullfile(sdir, stmp);

  % ------------------
  % read the RDR data
  % ------------------

  % RDR date and start time
  rid = rlist(fi).name(17:34);

  % working packet file
  ptmp = ['packet_', rid, '.dat'];
  pfile = fullfile(sdir, ptmp);

  % ******* TEST TEST TEST TEST ********
  keyboard
  continue

  %-----------------------------
  % process sci and eng packets
  %-----------------------------

  [sci, eng] = scipack(d1, eng);

  % check that we have sci data before we continue
  if isempty(sci)
    fprintf(1, 'rdr2sdr: no science packets, skipping file %s\n', rid)
    continue
  end

  % get the current wlaser from the eng packet data
  wlaser = metlaser(eng.NeonCal);
  if isnan(wlaser)
    fprintf(1, 'rdr2sdr: no valid wlaser value, skipping file %s\n', rid)
    continue
  end

  %-----------------------------
  % order and validate igm data
  %-----------------------------

  % RDR validation and ordering.  checkRDR returns data in column
  % order as nchan x 9 x nobs arrays, with nobs being the time steps

  try
    [igmLW, igmMW, igmSW, igmTime, igmFOR, igmSDR] = checkRDR(d1, rid);
  catch
     fprintf(1, 'rdr2sdr: checkRDR failed, skipping file %s\n', rid)
     continue
  end

  % this frees up a lot of of memory
  clear d1

  if isempty(igmTime)
    fprintf(1, 'rdr2sdr: no valid data, skipping file %s\n', rid)
    continue
  end

  if ~isempty(find(igmFOR > 31))
    fprintf(1, 'rdr2sdr: bad FOR values, skipping file %s\n', rid)
    continue
  end

  % --------------------------
  % group igm data into scans
  % --------------------------

  % Move obs to an nchan x 9 x 34 x nscan array, with gaps filled
  % with NaNs.  In the 3rd dim, indices 1:30 are ES data, 31:32 SP,
  % and 33:34 IT.  The time and FOR outputs are 34 x nscan arrays.  

  [scLW, scMW, scSW, scTime] = ...
         scanorder(igmLW, igmMW, igmSW, igmTime, igmFOR, igmSDR, rid);

  % done with checkRDR output
  clear igmLW igmMW igmSW igmTime igmFOR imgSDR

  % shift tails so scans start at FOR 1
  [scLW, scMW, scSW, scTime, scTail] = ...
         scantail(scLW, scMW, scSW, scTime, scTail);

  % match geo data to scanorder grid
  geo = geo_match(allgeo, scTime);

  if isempty(find(~isnan(geo.FORTime)))
    fprintf(1, 'rdr2sdr: no geo match, skipping file %s\n', rid)
    continue
  end

  % set the L1a error flag
  [m, nscan] = size(scTime);
  L1a_err = isnan(geo.FORTime) | geo.FORTime < 0 | isnan(scTime(1:30, :)) ...
            | cOR(geo.Latitude < -90 | 90 < geo.Latitude) ...
            | cOR(geo.Longitude < -180 | 180 < geo.Longitude) ...
            | abs(geo.FORTime ./ 1000 - (scTime(1:30, :) + geo.dtRDR)) > 1;

  if isempty(find(~L1a_err))
    fprintf(1, 'rdr2sdr: no valid L1a values, skipping file %s\n', rid)
    continue
  end

  % bad FOR warning message
  m = sum(L1a_err(:));
  if m > 0
    fprintf(1, 'rdr2sdr: warning - flagging %d bad FORs, file %s\n', m, rid)
  end

  % ------------------------
  % get uncalibrated spectra
  % -------------------------

  % get instrument and user grid parameters
  [instLW, userLW] = inst_params('LW', wlaser, opts);
  [instMW, userMW] = inst_params('MW', wlaser, opts);
  [instSW, userSW] = inst_params('SW', wlaser, opts);

  rcLW = igm2spec(scLW, instLW);
  rcMW = igm2spec(scMW, instMW);
  rcSW = igm2spec(scSW, instSW);

  clear scLW scMW scSW

  % -------------------------------------
  % radiometric and spectral calibration
  % -------------------------------------
  
  % get moving averages of SP and IT count spectra
  [avgLWSP, avgLWIT] = movavg_app(rcLW(:, :, 31:34, :), mvspan);
  [avgMWSP, avgMWIT] = movavg_app(rcMW(:, :, 31:34, :), mvspan);
  [avgSWSP, avgSWIT] = movavg_app(rcSW(:, :, 31:34, :), mvspan);

  [rLW, vLW, nLW] = calmain(instLW, userLW, rcLW, scTime, ...
                            avgLWIT, avgLWSP, sci, eng, geo, opts);

  [rMW, vMW, nMW] = calmain(instMW, userMW, rcMW, scTime, ...
                            avgMWIT, avgMWSP, sci, eng, geo, opts);

  [rSW, vSW, nSW] = calmain(instSW, userSW, rcSW, scTime, ...
                            avgSWIT, avgSWSP, sci, eng, geo, opts);

  clear rcLW rcMW rcSW

  % trim channel sets to user grid plus 2 guard channels
  % and return separate real values and complex residuals

  ugrid = cris_ugrid(userLW, 2);
  ix = interp1(vLW, 1:length(vLW), ugrid, 'nearest');
  cLW = single(imag(rLW(ix, :, :, :))); 
  rLW = single(real(rLW(ix, :, :, :)));  
  nLW = nLW(ix, :, :);
  vLW = vLW(ix);

  ugrid = cris_ugrid(userMW, 2);
  ix = interp1(vMW, 1:length(vMW), ugrid, 'nearest');
  cMW = single(imag(rMW(ix, :, :, :))); 
  rMW = single(real(rMW(ix, :, :, :))); 
  nMW = nMW(ix, :, :);
  vMW = vMW(ix);

  ugrid = cris_ugrid(userSW, 2);
  ix = interp1(vSW, 1:length(vSW), ugrid, 'nearest');
  cSW = single(imag(rSW(ix, :, :, :))); 
  rSW = single(real(rSW(ix, :, :, :))); 
  nSW = nSW(ix, :, :);
  vSW = vSW(ix);

  % L1b validation
  [L1b_err, L1b_stat] = ...
     checkSDR(vLW, vMW, vSW, rLW, rMW, rSW, cLW, cMW, cSW, ...
              userLW, userMW, userSW, L1a_err, rid, opts);

  %-------------------
  % save the SDR data
  %-------------------

  save(sfile, ...
       'instLW', 'instMW', 'instSW', 'userLW', 'userMW', 'userSW', ...
       'cLW', 'cMW', 'cSW', 'rLW', 'rMW', 'rSW', 'nLW', 'nMW', 'nSW', ...
       'vLW', 'vMW', 'vSW', 'scTime', 'sci', 'eng', 'geo', 'L1a_err', ...
       'L1b_err', 'L1b_stat', 'rid', '-v7.3')

end

