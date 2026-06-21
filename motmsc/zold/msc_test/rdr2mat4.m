% 
% NAME
%   rdr2mat4 - process 4-scan RDR h5 files to mat files 
%
% SYNOPSIS
%   rdr2mat4(doy, hdir, mdir)
%
% INPUTS
%   doy   - day-of-year directory, a 3-char string
%   hdir  - path to HDF RDR year (input)
%   mdir  - path to matlab RDR year (output)
%
% OUTPUT
%   a mat file RDR_<rid>.mat containing structs d1 and m1, as read
%   and organized by the MIT RDR reader
%
% DISCUSSION
%   This version is for 4-scan granules.  It drops files smaller than
%   6 Mb, those are probably 4-scan files.  When duplicate rid strings
%   (date and start times) are found, the most recent version is used.
%
%   The MIT reader has been modified to return sweep direction and to
%   be slightly less verbose
%

function rdr2mat4(doy, hdir, mdir)

% path to MIT readers
addpath /home/motteler/cris/MITreader380
addpath /home/motteler/cris/MITreader380/CrIS

% default path to HDF RDR year
if nargin < 2
  hdir = '/asl/data/cris/rdr4/hdf/2012/';
end

% default path to matlab RDR year
if nargin < 3
  mdir = '/asl/data/cris/rdr4/mat/2012/';
end

% full path to RDR h5 data source
hsrc = fullfile(hdir, doy);

% full path for matlab RDR output
mout = fullfile(mdir, doy);

% make sure the RDR directory exists
unix(['mkdir -p ', mout]);

% get initial list of HDF RDR files
hlist = dir(fullfile(hsrc, 'RCRIS-RNSCA_npp*.h5'));

% drop anything too big or too small
ix = find(6e6 < [hlist.bytes] & [hlist.bytes] < 7e6);
hlist = hlist(ix);

if isempty(hlist)
  fprintf(1, 'rdr2mat4 WARNING: no 4-scan files for doy %s\n', doy)
  return
end

% build a list of RIDs
for ix = 1 : length(hlist)
  rid = hlist(ix).name(17:34);
  rlist{ix} = rid;
end

% choose the last file if there are duplicate RIDs
[rlist, ix] = unique(rlist);
hlist = hlist(ix);

% loop on remaining HDF RDR files
for ix = 1 : length(hlist)

  % HDF RDR file
  hfile = fullfile(hsrc, hlist(ix).name);

  % matlab RDR file
  rid = hlist(ix).name(17:34);
  rtmp = ['RDR_', rid, '.mat'];
  rfile = fullfile(mout, rtmp);

  % check if the matlab RDR file already exists
  if exist(rfile) == 2
    continue
  end

  % call the MIT RDR reader
  fprintf(1, 'processing %s...\n', rid)
  try
    [d1, m1] = read_cris_hdf5_rdr(hfile);
  catch me
    fprintf(1, 'processing failed\n')
    fclose('all');
    continue
  end

  % close any dangling file handles
  fclose('all');

  % save the results
  save(rfile, 'd1', 'm1');

end

