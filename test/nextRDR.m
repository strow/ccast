%
% nextRDR - read successive RDR files
%
% mainly just a wrapper for read_cris_hdf5_rdr and checkRDR
%
% ri = zero initially, index of last valid read or end of list
%
% eng input is current eng packet or empty for no data
% eng output is the current or most recent eng packt
%
% igmTime is IET, translated with the ccast time lib
%

function [igmLW, igmMW, igmSW, igmTime, igmFOR, igmSD, ...
          sci, eng, timeOK, ri] = nextRDR(rdir, rlist, eng, ctmp, ri)

% Geo = RDR - dtRDR
dtRDR = 183e3;

% crude time range checks
tmin = 1.7e15;  % 14-Nov-2011
tmax = 2.4e15;  % 19-Jan-2034

% initialize outputs
igmLW = []; 
igmMW = []; 
igmSW = [];
igmTime = []; 
igmFOR = []; 
igmSD = [];
sci = [];
timeOK = [];

% reader bit trim default
btrim = 'btrim_cache.mat';

test = false;
if test
  % generate fake times for tests
    if ri < length(rlist), 
      ri = ri + 1;
      t0 = dnum2iet(datenum('1 jan 2017 12:00:00'));
      t0 = t0 + 3 * 8e6;   % 3 scans
%     t0 = t0 + 183e3;     % Geo to RDR shift
%     t0 = t0 + 2.1e3;     % timing error
      [igmTime, timeOK] = fakeTime(t0, 60, ri, 30);
    end
    return
end

% loop on file indices
no_data = true;
while no_data && ri < length(rlist)

  % read the next RDR HDF file
  ri = ri + 1;
  rid = rlist(ri).name(17:34);
  fprintf(1, 'nextRDR: reading RDR index %d file %s\n', ri, rid)
  rfile = fullfile(rdir, rlist(ri).name); 
  try
    [d1, m1] = read_cris_hdf5_rdr(rfile, ctmp, btrim);
    delete(ctmp);
  catch
    fprintf(1, 'nextRDR: error reading %s\n', rfile)
    fprintf(1, 'continuing with the next file...\n')
%   fclose('all'); % only MIT reader open files...
    delete(ctmp);
    continue
  end

  % read the sci and eng packets
  [sci, eng] = scipack(d1, eng);
  if isempty(sci)
    fprintf(1, 'nextRDR: no sci packets, skipping file %s\n', rid)
    continue
  end

  % RDR validation and ordering.  checkRDR returns data in column
  % order as nchan x 9 x nobs arrays, with nobs being the time steps
  % (this probably doesn't need a try/catch, crashes are very rare)
  try
    [igmLW, igmMW, igmSW, igmTime, igmFOR, igmSD] = checkRDR(d1, rid);
  catch
    fprintf(1, 'nextRDR: checkRDR failed, skipping file %s\n', rid)
    continue
  end

  % we got someting
  no_data = false;

  % this assumes checkRDR returns the old ccast UTC ms since 1958
  igmTime = tai2iet(utc2tai(igmTime/1000));

  % subtract dtRDR 
  igmTime = igmTime - dtRDR;

  % basic time QC
  timeOK = ~isnan(igmTime) & tmin <= igmTime & igmTime <= tmax;

end

