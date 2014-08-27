%
% NAME
%   rdr2sdr -- process RDR mat files to SDR mat files
%
% SYNOPSIS
%   [slist, msc] = rdr2sdr(flist, rdir, sdir, opts)
%
% INPUTS
%   flist  - list of RDR mat files
%   rdir   - directory for RDR input files
%   sdir   - directory for SDR output files
%   opts   - for now, everything else
%
% opts fields
%   mvspan   - span for local moving averages
%   sfileLW, MW, SW  - SRF matrix file by band
%   
% OUTPUTS
%   slist  - list of SDR mat files
%   msc    - optional output struct
%
% DISCUSSION
%
% rdr2sdr takes matlab RDR to matlab SDR data.  The files are
% RDR_<rid>.mat and SDR_<rid>.mat, where <rid> is a date and time
% string of the form tYYYYMMDD_dHHMMSSS, taken from the RDR HDF5
% file.  rdr2sdr ignores files that do not follow this convention
%
% the major processing steps are
%   checkRDR   - validate the RDR data
%   scipack    - process sci and eng packet data
%   igm2spec   - take igms to count spectra
%   scanorder  - group data into scans
%   geo_match  - match GCRSO and RDR scans
%   movavg_app - calculate or load moving averages
%   calmain    - radiometric and spectral calibration
%
% AUTHOR
%  H. Motteler, 20 Feb 2012
%

function [slist, msc] = rdr2sdr(flist, rdir, sdir, opts);

%----------------
% initialization
%----------------

% number of RDR files to process
nfile = length(flist);

% moving average span is 2 * mvspan + 1
mvspan = opts.mvspan;

% initial eng packet
eng = struct([]);

% initialize scan tail
scTail = struct;
scTail.nans = [];

% initialize output
msc = struct;
slist = struct([]);
nout = 0;

% load geo data, defines structs allgeo, allgid
if exist(opts.geofile, 'file')
  load(opts.geofile)
else
  fprintf(1, 'rdr2sdr: no geo file %s\n', opts.geofile)
  return
end

% ----------------------
% loop on RDR mat files
% ----------------------

for fi = 1 : nfile

  % -------------------------
  % load the matlab RDR data
  % -------------------------

  % matlab RDR input file
  rid = flist(fi).name(5:22);
  rtmp = ['RDR_', rid, '.mat'];
  rfile = fullfile(rdir, rtmp);

  % matlab SDR output file
  stmp = ['SDR_', rid, '.mat'];
  sfile = fullfile(sdir, stmp);

  % print a short status message
  if exist(rfile, 'file')
    fprintf(1, 'rdr2sdr: processing index %d file %s\n', fi, rid)
  else
    % skip processing if no matlab RDR file
    fprintf(1, 'rdr2sdr: RDR file missing, index %d file %s\n', fi, rid)
    continue
  end

  % load the RDR data, this defines structures d1 and m1
  load(rfile)

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

  [igmLW, igmMW, igmSW, igmTime, igmFOR, igmSDR] = checkRDR(d1, rid);

  % this frees up a lot of of memory
  clear d1

  if isempty(igmTime)
    fprintf(1, 'rdr2sdr: no valid data, skipping file %s\n', rid)
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

  % -----------------
  % get count spectra
  % -----------------

  % get instrument and user grid parameters
  [instLW, userLW] = inst_params('LW', wlaser, opts);
  [instMW, userMW] = inst_params('MW', wlaser, opts);
  [instSW, userSW] = inst_params('SW', wlaser, opts);

  rcLW = igm2spec(scLW, instLW);
  rcMW = igm2spec(scMW, instMW);
  rcSW = igm2spec(scSW, instSW);

  % -----------------------
  % radiometric calibration
  % -----------------------
  
  % get moving averages of SP and IT count spectra
  [avgLWSP, avgLWIT] = movavg_app(rcLW(:, :, 31:34, :), mvspan);
  [avgMWSP, avgMWIT] = movavg_app(rcMW(:, :, 31:34, :), mvspan);
  [avgSWSP, avgSWIT] = movavg_app(rcSW(:, :, 31:34, :), mvspan);

  [rLW, vLW] = calmain(instLW, userLW, rcLW, scTime, ...
                        avgLWIT, avgLWSP, sci, eng, geo, opts);

  [rMW, vMW] = calmain(instMW, userMW, rcMW, scTime, ...
                        avgMWIT, avgMWSP, sci, eng, geo, opts);

  [rSW, vSW] = calmain(instSW, userSW, rcSW, scTime, ...
                        avgSWIT, avgSWSP, sci, eng, geo, opts);

  %-------------------
  % save the SDR data
  %-------------------

  save(sfile, ...
       'instLW', 'instMW', 'instSW', 'userLW', 'userMW', 'userSW', ...
       'rLW', 'vLW', 'rMW', 'vMW', 'rSW', 'vSW', 'scTime', ...
       'sci', 'eng', 'geo', 'rid', '-v7.3')
  
  % keep a list of the SDR files
  nout = nout + 1;
  slist(nout).file = sfile;

end

