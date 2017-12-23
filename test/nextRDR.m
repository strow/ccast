%
% nextRDR - read successive RDR files
%
% SYNOPSIS
%    function [igmLW, igmMW, igmSW, igmTime, igmFOR, igmSD, ...
%              sci, eng, timeOK, ri] = nextRDR(rlist, ctmp, eng, ri)
%
% INPUTS
%   rlist   - NOAA RCRIS RDR file list
%   ctmp    - temp filename for packet data
%   eng     - prev eng packet, empty if none
%   ri      - previous file index in rlist
%
% OUTPUTS
%   igmLW   - nchan x 9 x nobs, LW interferograms
%   igmMW   - nchan x 9 x nobs, MW interferograms
%   igmSW   - nchan x 9 x nobs, SW interferograms
%   igmTime - nobs x 1, IGM times, IET time
%   igmFOR  - nobs x 1, IGM FOR values, 0-31
%   igmSD   - nobs x 1, IGM sweep direction, 0-1
%   sci     - sci (8-second) telemetery data
%   eng     - eng (4-minute) engineering data
%   timeOK  - igmTime valid flags
%   ri      - current file index
%
% DISCUSSION
%   mainly just a wrapper for read_cris_hdf5_rdr and checkRDR
%
%   ri iszero initially, index of last valid read or end of list
%
%   eng input is current eng packet or empty for no data
%   eng output is the current or most recent eng packt
%
%   igmTime is IET, translated with the ccast time lib
%

function [igmLW, igmMW, igmSW, igmTime, igmFOR, igmSD, ...
          sci, eng, timeOK, ri] = nextRDR(rlist, ctmp, eng, ri)

% MIT reader fid and larger globals
global fid idata qdata data diagint

% Geo = RDR - dtRDR
dtRDR = 183e3;

% crude time range checks
tmin = 1.7e15;  % 14-Nov-2011
tmax = 2.4e15;  % 19-Jan-2034

% initialize outputs
igmLW = [];   igmMW = []; 
igmSW = [];   igmTime = []; 
igmFOR = [];  timeOK = [];
igmSD = [];   sci = [];    

% reader bit trim default
btrim = 'btrim_cache.mat';

% edit for time tests, see fakeTime params
if false
  if ri < length(rlist), 
    ri = ri + 1;
    t0 = dnum2iet(datenum('1 jan 2017 12:00:00'));
    t0 = t0 + 3 * 8e6;   % 3 scans
%   t0 = t0 + 2.1e3;     % timing error
    ns = 60; % number of scans per file
    k = 4;   % obs index shift, 0-34 
    [igmTime, jx] = fakeTime(t0, ns, ri, k);
%   timeOK = rand(1, length(igmTime)) > 0;
    timeOK = rand(1, length(igmTime)) > 0.05;
    igmFOR = jx;
    igmLW = zeros(4, 9, 34, ns);
    igmMW = zeros(4, 9, 34, ns);
    igmSW = zeros(4, 9, 34, ns);
  end
  return % skip the regular nextRDR code
end

% loop on file indices
no_data = true;
while no_data && ri < length(rlist)

  % read the next RDR HDF file
  ri = ri + 1;
  rid = rlist(ri).name(17:34);
  fprintf(1, 'nextRDR: reading RDR index %d file %s\n', ri, rid)
  rfile = fullfile(rlist(ri).folder, rlist(ri).name); 
  try
    [d1, m1] = read_cris_hdf5_rdr(rfile, ctmp, btrim);
  catch
    fprintf(1, 'nextRDR: error reading %s\n', rfile)
    fprintf(1, 'continuing with the next file...\n')
    fid_all = fopen('all');
    if ismember(fid, fid_all);
      fclose(fid)
    end
    if exist(ctmp) == 2
      delete(ctmp);  % delete the ccsds packet temp file
    end
    continue
  end
  delete(ctmp);  % delete the ccsds packer temp file

  % clear the larger MIT reader globals
  clearvars -global fid idata qdata data diagint

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

  % clear the MIT reader output
  clear d1

  % this assumes checkRDR returns the old ccast UTC ms since 1958
  igmTime = tai2iet(utc2tai(igmTime/1000));

  % subtract dtRDR 
  igmTime = igmTime - dtRDR;

  % basic time QC
  timeOK = ~isnan(igmTime) & tmin <= igmTime & igmTime <= tmax;
  if sum(timeOK) == 0
    % if no good obs, clear and continue
    fprintf(1, 'nextRDR: no valid obs, skipping file %s\n', rid)
    igmLW = [];   igmMW = []; 
    igmSW = [];   igmTime = []; 
    igmFOR = [];  timeOK = [];
    igmSD = [];   sci = [];    
    continue
  end

  % we got someting
  no_data = false;
end

