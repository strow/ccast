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
% optional parameters include
%   d      - old driver struct (see discussion)
%   
% OUTPUTS
%   rlist  - list of RTP mat filenames
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

% Temporary working paths
addpath /home/motteler/cris/bcast
addpath /home/motteler/cris/bcast/davet

% number of SDR files to process
nfile = length(flist);

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

  % skip processing if no matlab RDR file
  if ~exist(sfile, 'file')
    fprintf(1, 'SDR file missing, index %d file %s\n', fi, rid)
    continue
  end

  % load the SDR data

  % load any needed meta data directly from hdf rdr file

  % do geolocation (calc or from files)

  % do time matching for sci, eng, geo (if from a file), meta data
  % and things like stats flags from the RDR mat file

  % loop on spec data in time order & write the RTP files

end

