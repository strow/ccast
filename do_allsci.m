%
% do_allsci -- save sci and eng data from RDR mat files
%
% do_allsci takes a directory and matlab RDR file list and saves
% sci and eng data as a struct arrays, only adding eng records when
% the values change.

% path to Dave's temp and ICT procedures
addpath /home/motteler/cris/rdr2spec5/davet2

% matlab RDR data 
% rdir = '/asl/data/cris/rdr_proxy/mat/2010/249';
rdir = '/asl/data/cris/rdr60/mat/2012/046';

% output directory
% odir = rdir
odir = '.';

flist = dir(sprintf('%s/RDR*.mat', rdir));

% initialize accumulation variables
eng1 = struct([]);
allsci = struct([]);
alleng = struct([]);

% loop on RDR mat files
for ir = 1 : length(flist)

  % rid is the RDR filename date and time substring
  rid = flist(ir).name(5:22);
  mfile = [rdir, '/', flist(ir).name];

  % load d1 and m1 from the MIT reader, from the call
  % [d1, m1] = read_cris_hdf5_rdr(h5file);
  load(mfile)

  % get sci and eng data from this file
  try 
    [sci, eng] = scipack(d1, eng1);
  catch sci_err
    rid
    sci_err
    continue
  end

  % accumulate the sci data
  allsci = [allsci, sci];

  % accumulate eng data whenever it changes
  if ~isempty(eng) && ~isequal(eng, eng1)
    alleng = [alleng, eng];
    eng1 = eng;
  end
end

% keep science packets sorted by time
[tx, ix] = sort([allsci(:).time]);
allsci = allsci(ix);

% save the results
dstr = rid(2:9);
save([odir, '/allsci', dstr], 'allsci', 'alleng')

