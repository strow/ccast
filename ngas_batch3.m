
% process data with the NGAS reader

more off

addpath /home/motteler/cris/NGAS/reader_1.0/

% dsrc  = '/asl/data/cris/rdr_proxy/hdf/2010/249';
dsrc  = '/asl/data/cris/rdr60/hdf/2012/039';

% dout = '/asl/data/cris/rdr_proxy/ng/2010/249';
dout = '/asl/data/cris/rdr60/ng/2012/039';

indir = '/home/motteler/cris/tmp_ngas';

dlist = dir(sprintf('%s/RCRIS-RNSCA_npp*.h5', dsrc));
% dlist = dir(sprintf('%s/RCRIS-RNSCA_npp*d20120208_t1835268*.h5', dsrc));

s = 0;

% for i = 1 : length(dlist)
for i = 140

  % clean out the tmp directory
  % display(sprintf('rm %s/*', indir));
  [s,t] = unix(sprintf('rm %s/* 2>/dev/null', indir));
  % if s ~= 0, error('unix tmp cleanup'), end

  % copy data to tmp dir
  % display(sprintf('cp %s/%s %s', dsrc, dlist(i).name, indir));
  [s,t] = unix(sprintf('cp %s/%s %s', dsrc, dlist(i).name, indir));
  if s ~= 0, error('unix cp'), end

  % build full path name to output directory
  stmp = sprintf('RMAT_%s', dlist(i).name(17:34));
  outdir = sprintf('%s/%s', dout, stmp);

  % delete any current directory by that name
  if exist(outdir) == 7
    % display(sprintf('rm -r %s', outdir));
    [s,t] = unix(sprintf('rm -r %s', outdir));
    if s ~= 0, error('unix outdir cleanup'), end
  end

  % create the output directory
  % display(sprintf('mkdir %s', outdir));
  [s,t] = unix(sprintf('mkdir %s', outdir));
  if s ~= 0, error('unix outdir create'), end

  % call the ngas reader
  fprintf(1, 'processing %s...\n', stmp)
  try
    CrISRDR_Reader(indir, outdir, 'h5', 15, 'Survey');
    CrISRDR_Reader(indir, outdir, 'h5', 15, 'AllSci');
  catch me
    fprintf(1, 'processing failed\n')
  end
end

