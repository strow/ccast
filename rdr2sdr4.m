%
% NAME
%   rdr2sdr4 -- quick check for out-of-order 4-scan data
%
% SYNOPSIS
%   msc = rdr2sdr4(flist, rdir)
%
% INPUTS
%   flist  - list of RDR mat files
%   rdir   - directory for RDR input files
%
% OUTPUTS
%   msc    - optional output struct
%
% DISCUSSION
%
% major processing steps are
%   checkRDR   - validate the RDR data
%   scipack    - process sci and eng packets
%   readspec   - take igms to count spectra
%   scanorder  - group data into scans
%
% AUTHOR
%  H. Motteler, 20 Feb 2012
%

function msc = rdr2sdr4(flist, rdir);

% number of RDR files to process
nfile = length(flist);

% initialize sci and eng packet struct's
eng1 = struct([]);
allsci = struct([]);

% initialize output structs
msc = struct;

tmin = ones(nfile,1) * NaN;
tmax = ones(nfile,1) * NaN;

% -------------------------
% loop on MIT RDR mat files
% -------------------------

for fi = 1 : nfile

  % --------------------------
  % load and validate MIT data
  % --------------------------

  % MIT matlab RDR data file
  rid = flist(fi).name(5:22);
  rtmp = ['RDR_', rid, '.mat'];
  rfile = fullfile(rdir, rtmp);

% % print a short status message
% if exist(rfile, 'file')
%   fprintf(1, 'rdr2sdr4: processing index %d file %s\n', fi, rid)
% else
%   % skip processing if no matlab RDR file
%   fprintf(1, 'rdr2sdr4: RDR file missing, index %d file %s\n', fi, rid)
%   continue
% end

  % load the RDR data, defines structures d1 and m1
  load(rfile)

  % RDR validation.  checkRDR returns data as nchan x 9 x nobs
  % arrays, ordered by time
  [igmLW, igmMW, igmSW, igmTime, igmFOR, igmSDR] = checkRDRf(d1, rid);

  if isempty(igmTime)
    fprintf(1, 'rdr2sdr4: no valid data, skipping file %s\n', rid)
    continue
  end

% % process sci and eng packets
% [sci, eng] = scipack(d1, eng1);

  % this frees up a big chunk of memory
  clear d1

% % skip to next file if we don't have any science packets
% if isempty(sci)
%   fprintf(1, 'rdr2sdr4: no science packets, skipping file %s\n', rid)
%   continue
% end

  % get wlaser from the eng packet data
% wlaser = metlaser(eng.NeonCal);
  wlaser = 773;

  % get instrument and user grid parameters
  [instLW, userLW] = inst_params('LW', wlaser);
  [instMW, userMW] = inst_params('MW', wlaser);
  [instSW, userSW] = inst_params('SW', wlaser);

  % -----------------
  % get count spectra
  % -----------------

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

  [scLW, scMW, scSW, scTime, scFOR] = ...
           scanorder(rcLW, rcMW, rcSW, igmTime, igmFOR, igmSDR, rid);

  [m, n, k, nscan] = size(scLW);

  % clear rcLW rcMW rcSW
  
  % [m, n, k, nscan]

  tmin(fi) = min(scTime(:));
  tmax(fi) = max(scTime(:));

  if fi > 1 && tmax(fi-1) >= tmin(fi)
    fprintf(1, 'rdr2sdr4: timeline overlap %d file %s\n', fi, rid)
  end

end

msc.tmin = tmin;
msc.tmax = tmax;

