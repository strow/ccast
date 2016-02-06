% 
% NAME
%   rdr2mat - process RDR h5 files to mat files 
%
% SYNOPSIS
%   rdr2mat(doy, hdir, mdir, btrim)
%
% INPUTS
%   doy   - day-of-year directory, a 3-char string
%   hdir  - path to HDF RDR year (input)
%   mdir  - path to matlab RDR year (output)
%   btrim - optional bit trim mask cache file
%
% OUTPUT
%   a mat file RDR_<rid>.mat containing structs d1 and m1, as read
%   and organized by the MIT RDR reader
%
% DISCUSSION
%   This version is for 60-scan granules.  It drops files smaller than
%   6 Mb, those are probably 4-scan files.  When duplicate rid strings
%   (date and start times) are found, the most recent version is used.
%
%   The MIT reader has been modified to return sweep direction and to
%   be slightly less verbose
%

function rdr2mat(doy, hdir, mdir, btrim)

% default bit trim cache file
if nargin < 4
  btrim = 'btrim_cache.mat';
end

% get a CCSDS temp filename
jdir = getenv('JOB_SCRATCH_DIR');
pstr = getenv('SLURM_PROCID');
if ~isempty(jdir) && ~isempty(pstr)
  ctmp = fullfile(jdir, sprintf('ccsds_%s.tmp', pstr));
else
  rng('shuffle');
  ctmp = sprintf('ccsds_%03d.tmp', randi(999));
end

% full path to RDR h5 data source
hsrc = fullfile(hdir, doy);

% full path for matlab RDR output
mout = fullfile(mdir, doy);

% make sure the RDR directory exists
unix(['mkdir -p ', mout]);

% get initial list of HDF RDR files
hlist = dir(fullfile(hsrc, 'RCRIS-RNSCA_npp*.h5'));

% drop 4-scan or smaller files
ix = find([hlist.bytes] > 8e6);
hlist = hlist(ix);

if isempty(hlist)
  fprintf(1, 'rdr2mat: no 60-scan files for doy %s\n', doy)
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

% % check if the matlab RDR file already exists
% if exist(rfile) == 2
%   continue
% end

  % call the MIT RDR reader
  fprintf(1, 'rdr2mat: processing %s...\n', rid)
  try
    [d1, m1] = read_cris_hdf5_rdr(hfile, ctmp, btrim);
  catch me
    fprintf(1, 'rdr2mat: processing failed\n')
    fclose('all');
    delete(ctmp);
    continue
  end

  % clean up
  fclose('all');
  delete(ctmp);

  % save the results
  save(rfile, 'd1', 'm1');

end

