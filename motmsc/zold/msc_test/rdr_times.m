
% read an RDR mat file and compare internal time with filename and
% optionally the RDR HDF attribute time.  result: these are all in
% agreement with the uncorrected internal time.  The only exception
% was 3 July 2012, around the time of the RDR time shift.

% select day-of-year
doy = '185';  % RDR 1 sec shift day

% select an RDR file by index
rix = 111; % RDR 1 sec shift time

% path to HDF RDR year
hdir = '/asl/data/cris/rdr60/hdf/2012/';

% path to matlab RDR year
mdir = '/asl/data/cris/rdr60/mat/2012/';

% full path to RDR h5 data source
hsrc = fullfile(hdir, doy);

% full path for matlab RDR output
mout = fullfile(mdir, doy);

% get initial list of HDF RDR files
hlist = dir(fullfile(hsrc, 'RCRIS-RNSCA_npp*.h5'));

% drop 4-scan or smaller files
ix = find([hlist.bytes] > 7e6);
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

% HDF RDR file
hfile = fullfile(hsrc, hlist(rix).name);

% matlab RDR file
rid = hlist(rix).name(17:34);
rtmp = ['RDR_', rid, '.mat'];
rfile = fullfile(mout, rtmp);

load(rfile)

[igmLW, igmMW, igmSW, igmTime, igmFOR, igmSDR] = checkRDRf(d1, rid);

t0 = min(igmTime);

% factor to convert MIT time to IET, t_mit * mwt = t_ngas
mwt = 8.64e7;

t_mit = t0 / mwt;
datestr(t_mit + datenum('1-jan-1958'))

rid

% do this in a separate window to check attribute times
% h5disp(hfile)


