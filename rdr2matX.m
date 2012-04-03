
% process RDR h5 files to mat files
%
% skips existing mat RDR files

more off

% addpath /home/motteler/cris/MITreader341
% addpath /home/motteler/cris/MITreader341/CrIS
% addpath /home/motteler/cris/MITreader341x
% addpath /home/motteler/cris/MITreader341x/CrIS
% addpath /home/motteler/cris/MITreader347
% addpath /home/motteler/cris/MITreader347/CrIS
% addpath /home/motteler/cris/MITreader351
% addpath /home/motteler/cris/MITreader351/CrIS
addpath /home/motteler/cris/MITreader367
addpath /home/motteler/cris/MITreader367/CrIS

% h5 RDR data source
% hdir  = '/asl/data/cris/rdr_proxy/hdf/2010/249';
hdir = '/asl/data/cris/rdr60/hdf/2012/042';

hlist = dir(sprintf('%s/RCRIS-RNSCA_npp*.h5', hdir));

% matlab RDR output directory
% rdir = '/asl/data/cris/rdr_proxy/mat/2010/249';
rdir = '/asl/data/cris/rdr60/mat/2012/042X';

% loop on HDF RDR files
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
