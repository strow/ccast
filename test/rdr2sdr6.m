%
% NAME
%   rdr2sdr - take RCRIS and GCRSO files to ccast SDRs
%
% SYNOPSIS
%   rdr2sdr(rdir, gdir, sdir, opts)
%
% INPUTS
%   rdir  - NOAA RCRIS RDR files
%   gdir  - NOAA GCRSO geo files
%   sdir  - SDR output files
%   opts  - options struct
%
% opts fields
%   see recent driver scripts
%   
% OUTPUT
%   SDR mat files
%
% DISCUSSION
%   drives main processing loop from RDR files
%
% AUTHOR
%  H. Motteler, 24 Nov 2017
%

% function rdr2sdr(rdir, gdir, sdir, opts);
function rdr2sdr

addpath ../source
addpath ../davet
addpath ../motmsc/time
addpath ../readers/MITreader380b
addpath ../readers/MITreader380b/CrIS

rdir = '/asl/data/cris/rdr60/2017/181';
gdir = '/asl/data/cris/sdr60/2017/181';
sdir = './sdr_test';
opts = struct;
opts.mvspan = 4;
nscanSDR = 60;
nscanRDR = 60;
nscanGeo = 60;

%---------------
% general setup 
%---------------

btrim = 'btrim_cache.mat';

% get a CCSDS temp filename
jdir = getenv('JOB_SCRATCH_DIR');
pstr = getenv('SLURM_PROCID');
if ~isempty(jdir) && ~isempty(pstr)
  ctmp = fullfile(jdir, sprintf('ccsds_%s.tmp', pstr));
else
  ctmp = sprintf('ccsds_%03d.tmp', randi(9999));
end

% create the output path, if needed
unix(['mkdir -p ', sdir]);

% moving average span is 2 * mvspan + 1
mvspan = opts.mvspan;

% initial eng packet
eng = struct;

% get a list of GCRSO geo files
glist = dir2list(gdir, 'GCRSO', nscanGeo);
glist = glist(1:4);  % TEST TEST TEST

% get a list of RCRIS RDR files
rlist = dir2list(rdir, 'RCRIS', nscanRDR);
rlist = rlist(1:4);  % TEST TEST TEST

% geo initial read
gi = 0;
[geo, geoTime, geoTimeOK, gi] = nextGeo(gdir, glist, gi);
nobsGeo = length(geoTime);
gptr = 0;

% RDR initial read
ri = 0;
eng = [];
[igmLW, igmMW, igmSW, igmTime, igmFOR, igmSD, ...
  sci, eng, igmTimeOK, ri] = nextRDR(rdir, rlist, eng, ctmp, ri);
nobsRDR = length(igmTime);
rptr = 0;

nobsRDR = length(igmTime);
[nchanLW, ~, ~] = size(igmLW);
[nchanMW, ~, ~] = size(igmMW);
[nchanSW, ~, ~] = size(igmSW);

% Initialize the scan-order arrays
si = 1;
scLW = NaN(nchanLW, 9, 34, nscanSDR);
scMW = NaN(nchanMW, 9, 34, nscanSDR);
scSW = NaN(nchanSW, 9, 34, nscanSDR);
scTime = NaN(1, 34 * nscanSDR);
nobsSC = length(scTime);
sptr = 0;

% set SDR time grid to first RDR FOR 1
ix = find(igmFOR == 1, 1);
t0 = igmTime(ix);
datestr(iet2dnum(t0))
[scTime, jx] = fakeTime(t0, nscanSDR, 1, 0);

% test vars
nmatch = 0;
nloop = 0;
ncopy = 0;

% loop on obs (ES, SP, and IT looks)
% nextGptr and nextRptr return next valid buffer pointers or 
% zero if no more data; geoTime not-empty implies gptr is valid
nextGptr
nextRptr
nextSptr
while ~isempty(geoTime) && ~isempty(igmTime)

  tg = geoTime(gptr);
  tr = igmTime(rptr);
  ts = scTime(sptr);

  % match values within 2ms
  if abs(tg - tr) < 2e3
     % found an RDR-Geo match
     nmatch = nmatch + 1;
     % let sptr catch up
     while ts < tg - 2e3;
       nextSptr
       ts = scTime(sptr);
     end  
     % 3-way match, so copy
     if abs(ts - tg) < 2e3
       % ** do the copy here **
       ncopy = ncopy + 1;
       nextSptr
     end
     % if ts > tg, we just continue until obs catch up
     nextGptr
     nextRptr
  elseif(abs(tg - tr) < 100e3)
     % too close for comfort
     fprintf(1, 'rdr2sdr: warning 2 < dT < 100 ms\n');
     nextGptr
     nextRptr
  elseif tg > tr, nextRptr;
  elseif tr > tg, nextGptr;
  else, error('cosmic meltdown'), end
  nloop = nloop + 1;
end

fprintf(1, 'nmatch = %d\n', nmatch)
fprintf(1, 'ncopy  = %d\n', ncopy)
% fprintf(1, 'nloop = %d\n', nloop)
% fprintf(1, 'nloop - nmatch = %d\n', nloop - nmatch)

keyboard

function nextSptr
  sptr = sptr + 1;
  if sptr > nobsSC
    fprintf(1, 'writing SDR file %d\n', si)
    sptr = 1;
    si = si + 1;
    t0 = scTime(end) + 800e3;
    scTime = fakeTime(t0, nscanSDR, si, 0);
    nobsSC = length(scTime);
    datestr(iet2dnum(t0))
  end
end

function incGptr
  gptr = gptr + 1;
  if gptr > nobsGeo
    [geo, geoTime, geoTimeOK, gi] = nextGeo(gdir, glist, gi);
    if isempty(geoTime), 
      gptr = 0; 
    else 
      gptr = 1; 
      nobsGeo = length(geoTime);
    end
  end
end 

function nextGptr
  incGptr;
  while ~isempty(geoTime) && ~geoTimeOK(gptr)
     incGptr;
  end
end

function incRptr
  rptr = rptr + 1;
  if rptr > nobsRDR
    [igmLW, igmMW, igmSW, igmTime, igmFOR, igmSD, ...
      sci, eng, igmTimeOK, ri] = nextRDR(rdir, rlist, eng, ctmp, ri);
    nobsRDR = length(igmTime);
    if isempty(igmTime)
      rptr = 0; 
    else 
      rptr = 1; 
      nobsRDR = length(igmTime);
    end
  end
end 

function nextRptr
  incRptr;
  while ~isempty(igmTime) && ~igmTimeOK(rptr)
     incRptr;
  end
end

end % main

