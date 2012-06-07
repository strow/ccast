% 
% NAME
%   sci_daily -- save sci and eng data from RDR mat files
%
% SYNOPSIS
%   sci_daily(doy, rdir, odir)
%
% INPUTS
%   doy   - directory of RDR mat files, typically doy
%   rdir  - path to the doy directory, typically year
%   odir  - output directory
%
% OUTPUT
%   A matfile odir/allsciYYYYMMDD.mat containing structs allsci
%   and alleng
%
% DISCUSSION
% 
%   sci_daily takes a directory and matlab RDR file list and saves
%   sci and eng data as a struct arrays, only adding eng records when
%   the values change.  Most of the work is done by scipack.m
%

function sci_daily(doy, rdir, odir)

% set paths here, for now
addpath /home/motteler/cris/bcast
addpath /home/motteler/cris/bcast/davet

% default path to matlab RDR year
if nargin < 2
  rdir = '/asl/data/cris/rdr60/mat/2012/';
end

% default output directory
if nargin < 3
  odir = '/home/motteler/cris/data/2012/daily/';  
end

% full path to matlab RDR data
rsrc = fullfile(rdir, doy);

% list of RDR mat files
flist = dir(fullfile(rsrc, 'RDR*.mat'));

% initialize accumulation variables
eng1 = struct([]);
allsci = struct([]);
alleng = struct([]);

% loop on RDR mat files
for ir = 1 : length(flist)

  % rid is the RDR filename date and time substring
  rid = flist(ir).name(5:22);
  mfile = fullfile(rsrc, flist(ir).name);

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
save(fullfile(odir, ['allsci', dstr]), 'allsci', 'alleng')

