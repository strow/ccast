%
% NAME
%   rdr2dmp -- save selected internal values from rdr2sdr
%
% SYNOPSIS
%   [slist, msc] = rdr2dmp(flist, rdir, sdir, opts)
%
% INPUTS
%   flist  - list of RDR mat files
%   rdir   - directory for RDR input files
%   sdir   - directory for DMP output files
%   opts   - just a placeholder
%   
% OUTPUTS
%   slist  - list of DMP mat files
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
% rdr2dmp is part of a processing chain in which the major steps
% communicate by files, with the following naming scheme
%
%   RDR_<rid>.mat  -- RDR mat files, from rdr2mat
%   DMP_<rid>.mat  -- DMP mat files, from this procedure
%
% where <rid> is a string of the form tYYYYMMDD_dHHMMSSS taken
% from the original RDR HDF5 file.
%
% rdr2dmp does not directly load the filenames in flist, it builds
% the expected names from <rid> and tries to load that.  The idea is
% that anything that fails to conform to the naming scheme should be
% a fatal error.
%
% If we find pre-calculated moving average files in avgdir, we use
% those instead of locally calculated values
%
% AUTHOR
%  H. Motteler, 20 Feb 2012
%

function [slist, msc] = rdr2dmp(flist, rdir, sdir, opts);

% number of RDR files to process
nfile = length(flist);

% moving average span is 2 * mvspan + 1
mvspan = 4;

% initialize sci and eng packet struct's
eng1 = struct([]);
allsci = struct([]);

% initialize output structs
msc = struct;
slist = struct([]);
nout = 0;

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

  % our matlab DMP output file
  stmp = ['DMP_', rid, '.mat'];
  sfile = fullfile(sdir, stmp);

  % print a short status message
  if exist(rfile, 'file')
    fprintf(1, 'rdr2dmp: processing index %d file %s\n', fi, rid)
  else
    % skip processing if no matlab RDR file
    fprintf(1, 'rdr2dmp: RDR file missing, index %d file %s\n', fi, rid)
    continue
  end

  % load the RDR data, defines structures d1 and m1
  load(rfile)

  % RDR validation.  checkRDR returns data as nchan x 9 x nobs
  % arrays, ordered by time
  [igmLW, igmMW, igmSW, igmTime, igmFOR, igmSDR] = checkRDRf(d1, rid);

  if isempty(igmTime)
    fprintf(1, 'rdr2dmp: no valid data, skipping file %s\n', rid)
    continue
  end

  % process sci and eng packets
  [sci, eng] = scipack(d1, eng1);

  % this frees up a big chunk of memory
  clear d1

  % skip to next file if we don't have any science packets
  if isempty(sci)
    fprintf(1, 'rdr2dmp: no science packets, skipping file %s\n', rid)
    continue
  end

  % get wlaser from the eng packet data
  wlaser = metlaser(eng.NeonCal);

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

  %------------------------------
  % save data as an DMP mat file
  %------------------------------
  save(sfile, ...
       'instLW', 'instMW', 'instSW', 'userLW', 'userMW', 'userSW', ...
       'igmLW', 'igmMW', 'igmSW', 'igmTime', 'igmFOR', 'igmSDR', ...
       'rcLW', 'rcMW', 'rcSW', 'sci', 'eng', 'rid')
  
  % keep a list of the DMP files
  nout = nout + 1;
  slist(nout).file = sfile;

end

