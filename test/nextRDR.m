%
% nextRDR - read successive RDR files
%
% mainly just a wrapper for read_cris_hdf5_rdr and checkRDR
%
% ri is the file index pointer
%   ri = 0, initial or done, geoTime is empty
%   1 <= ri <= n, geoTime valid, file ri is in the buffer
%
% eng input is current eng packet or empty for no data
% eng output is the current or most recent eng packt
%
% igmTime is returned as TAI, translated with the ccast time lib
%
% dtRDR = 4817 + 4 * 8000;
% t1 = igmTime + dtRDR; % ms
% t2 = utc2tai(igmTime/1000)) * 1000;  % ms
% t2(1:4) - t1(1:4) % 183 ms, true - ccast

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

% % use fake times for tests
%   ri = ri + 1;
%   if ri > length(rlist), 
%     ri = 0;
%   else
%     t0 = dnum2iet(datenum('1 jan 2017 12:00:00'));
%     t0 = t0 + 2 * 8e6;   % 2 scans
%     t0 = t0 + 183e3;     % Geo to RDR shift
% %   t0 = t0 + 2.1e3;     % timing error
%     [igmTime, timeOK] = fakeTime(t0, 60, ri, 4);
%   end
%   return

% loop on file indices
ri = ri + 1;
no_data = true;
while no_data && ri <= length(rlist)

  % read the next RDR HDF file
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
    ri = ri + 1;
    continue
  end

  % read the sci and eng packets
  [sci, eng] = scipack(d1, eng);
  if isempty(sci)
    fprintf(1, 'nextRDR: no sci packets, skipping file %s\n', rid)
    ri = ri + 1;
    continue
  end

  % RDR validation and ordering.  checkRDR returns data in column
  % order as nchan x 9 x nobs arrays, with nobs being the time steps
  % (this probably doesn't need a try/catch, crashes are very rare)
  try
    [igmLW, igmMW, igmSW, igmTime, igmFOR, igmSD] = checkRDR(d1, rid);
  catch
    fprintf(1, 'nextRDR: checkRDR failed, skipping file %s\n', rid)
    ri = ri + 1;
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

% wrap file index pointer to zero
if ri > length(rlist), ri = 0; end

