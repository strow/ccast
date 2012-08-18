%
% NAME
%   sdr2rtp -- process SDR mat files to RTP files
%
% SYNOPSIS
%   [rlist, msc] = sdr2rtp(flist, sdir, rdir, opts)
%
% INPUTS
%   flist  - list of SDR mat filenames
%   sdir   - directory for SDR input files
%   rdir   - directory for RTP output files
%   opts   - optional parameter struct
%
% OUTPUTS
%   rlist  - list of RTP mat files
%   msc    - optional output struct
%
% DISCUSSION
%
% this is just a skeleton
%
% sdr2rtp is part of a processing chain in which the major
% steps communicate by files.  These are named as follows:
%
%   RDR_<rid>.mat  -- RDR mat files, from rdr2mat
%   avg_<rid>.mat  -- moving average files, from movavg_pre
%   SDR_<rid>.mat  -- SDR mat files, from this procedure
%
% where <rid> is a string of the form tYYYYMMDD_dHHMMSSS taken
% from the original RDR HDF5 file.
%

function [rlist, msc] = sdr2rtp(flist, sdir, rdir, opts);

% number of SDR files to process
nfile = length(flist);

% initialize output structs
msc = struct;
rlist = struct([]);
nout = 0;

% ---------------------
% loop on SDR mat files
% ---------------------

for fi = 1 : nfile

  % -----------------
  % load the SDR data
  % -----------------

  % rid string and SDR filename
  rid = flist(fi).name(5:22);
  stmp = ['SDR_', rid, '.mat'];
  sfile = [sdir, '/', stmp];

  % RTP output filename
  rtmp = ['RTP_', rid, '.mat'];
  rfile = fullfile(rdir, rtmp);

  % skip processing if no matlab SDR file
  if ~exist(sfile, 'file')
    fprintf(1, 'SDR file missing, index %d file %s\n', fi, rid)
    continue
  end

  % load the SDR data, defines variables instLW, instMW, instSW,
  % userLW, userMW, userSW, rLW, vLW, rMW, vMW, rSW, vSW, scTime,
  % sci, eng, geo, rid
  load(sfile)
  
  keyboard

  % keep a list of the rtp files
  nout = nout + 1;
  rlist(nout).file = sfile;

end

