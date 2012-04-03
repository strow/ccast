
% process RDR h5 files to mat files
%
% This version is for 60-scan granules.  It drops files smaller than
% 6 Mb, those are probably 4-scan files.  When duplicate rid strings
% (date and start times) are found, the most recent version is used.

function rdr2mat(doy)

more off
% clear all

% addpath /home/motteler/cris/MITreader341
% addpath /home/motteler/cris/MITreader341/CrIS
% addpath /home/motteler/cris/MITreader351
% addpath /home/motteler/cris/MITreader351/CrIS
addpath /home/motteler/cris/MITreader380
addpath /home/motteler/cris/MITreader380/CrIS

% 2012 date as day of year
% doy = '064';

% h5 RDR data source
hdir = ['/asl/data/cris/rdr60/hdf/2012/', doy];

% matlab RDR output directory
rdir = ['/asl/data/cris/rdr60/mat/2012/', doy];

% make sure the RDR directory exists
unix(['mkdir -p ', rdir]);

% get initial list of HDF RDR files
hlist = dir(sprintf('%s/RCRIS-RNSCA_npp*.h5', hdir));

% drop small files
ix = find([hlist.bytes] > 6000000);
hlist = hlist(ix);

if isempty(hlist)
  fprintf(1, 'rdr2mat WARNING: no 60-scan files for doy %s\n', doy)
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
  hfile = [hdir, '/', hlist(ix).name];

  % matlab RDR file
  rid = hlist(ix).name(17:34);
  rtmp = ['RDR_', rid, '.mat'];
  rfile = [rdir, '/', rtmp];

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
