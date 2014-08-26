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
% rdr2sdr takes matlab RDR to matlab SDR data
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
% the input RDR and output SDR files use the naming scheme 
%   RDR_<rid>.mat  -- RDR mat files, from rdr2mat
%   SDR_<rid>.mat  -- SDR mat files, from rdr2sdr
% where <rid> is a string of the form tYYYYMMDD_dHHMMSSS from 
% the RDR HDF5 file.  rdr2sdr ignores files that do not follow 
% this convention
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

% initialize sci and eng packet struct's
eng1 = struct([]);
allsci = struct([]);

% initialize scan tail
scTail = struct;
scTail.nans = [];

% initialize output structs
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

  % -------------------------------
  % load and validate the RDR data
  % -------------------------------

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

  % RDR validation and ordering.  checkRDR returns data in column
  % order as nchan x 9 x nobs arrays, with nobs being the time steps
  [igmLW, igmMW, igmSW, igmTime, igmFOR, igmSDR] = checkRDR(d1, rid);

  if isempty(igmTime)
    fprintf(1, 'rdr2sdr: no valid data, skipping file %s\n', rid)
    continue
  end

  %-----------------------------
  % process sci and eng packets
  %-----------------------------

  [sci, eng] = scipack(d1, eng1);

  % this frees up a big chunk of memory
  clear d1

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

  % -----------------
  % get count spectra
  % -----------------

  % get instrument and user grid parameters
  [instLW, userLW] = inst_params('LW', wlaser, opts);
  [instMW, userMW] = inst_params('MW', wlaser, opts);
  [instSW, userSW] = inst_params('SW', wlaser, opts);

  rcLW = igm2spec(igmLW, instLW);
  rcMW = igm2spec(igmMW, instMW);
  rcSW = igm2spec(igmSW, instSW);

  [nchLW, m, n] = size(rcLW);
  [nchMW, m, n] = size(rcMW);
  [nchSW, m, n] = size(rcSW);

  clear igmLW igmMW igmSW

  % ---------------------
  % group data into scans
  % ---------------------

  % Move obs to an nchan x 9 x 34 x nscan array, with gaps filled
  % with NaNs.  In the 3rd dim, indices 1:30 are ES data, 31:32 SP,
  % and 33:34 IT.  The time and FOR outputs are 34 x nscan arrays.  
  % Note that if the data from checkRDR has no time or FOR gaps and
  % starts with FOR 1, this is just a reshape.

  [scLW, scMW, scSW, scTime] = ...
         scanorder(rcLW, rcMW, rcSW, igmTime, igmFOR, igmSDR, rid);

  % clean up checkRDR output
  clear rcLW rcMW rcSW

  % shift tails so scans start at FOR 1
  [scLW, scMW, scSW, scTime, scTail] = ...
         scantail(scLW, scMW, scSW, scTime, scTail);

  % match geo data to scanorder grid
  geo = geo_match(allgeo, scTime);

  % ----------------------------------------------
  % get moving averages of SP and IT count spectra
  % ----------------------------------------------

  [avgLWSP, avgLWIT] = movavg_app(scLW(:, :, 31:34, :), mvspan);
  [avgMWSP, avgMWIT] = movavg_app(scMW(:, :, 31:34, :), mvspan);
  [avgSWSP, avgSWIT] = movavg_app(scSW(:, :, 31:34, :), mvspan);

  % -----------------------
  % radiometric calibration
  % -----------------------
  
  [rLW, vLW] = calmain(instLW, userLW, scLW, scTime, ...
                        avgLWIT, avgLWSP, sci, eng, geo, opts);

  [rMW, vMW] = calmain(instMW, userMW, scMW, scTime, ...
                        avgMWIT, avgMWSP, sci, eng, geo, opts);

  [rSW, vSW] = calmain(instSW, userSW, scSW, scTime, ...
                        avgSWIT, avgSWSP, sci, eng, geo, opts);

  % save data as an SDR mat file
  save(sfile, ...
       'instLW', 'instMW', 'instSW', 'userLW', 'userMW', 'userSW', ...
       'rLW', 'vLW', 'rMW', 'vMW', 'rSW', 'vSW', 'scTime', ...
       'sci', 'eng', 'geo', 'rid')
  
  % keep a list of the SDR files
  nout = nout + 1;
  slist(nout).file = sfile;

end

