% 
% NAME
%   geo_cat - save a day's worth of GCRSO data in a mat file
%
% SYNOPSIS
%   geo_cat(doy, gdir, odir)
%
% INPUTS
%   doy    - directory of GCRSO files, typically doy
%   gdir   - path to the doy directory, typically year
%   odir   - output directory
%
% OUTPUT
%
%  A matfile odir/allgeoYYYYMMDD.mat containing a struct allgeo with
%  fields
%                FORTime: [30 x N int64]
%                 Height: [9 x 30 x N single]
%               Latitude: [9 x 30 x N single]
%              Longitude: [9 x 30 x N single]
%                MidTime: [N x 1 int64]
%               PadByte1: [N x 1 uint8]
%         QF1_CRISSDRGEO: [N x 1 uint8]
%             SCAttitude: [3 x N single]
%             SCPosition: [3 x N single]
%             SCVelocity: [3 x N single]
%  SatelliteAzimuthAngle: [9 x 30 x N single]
%         SatelliteRange: [9 x 30 x N single]
%   SatelliteZenithAngle: [9 x 30 x N single]
%      SolarAzimuthAngle: [9 x 30 x N single]
%       SolarZenithAngle: [9 x 30 x N single]
%              StartTime: [N x 1 int64]
%
%  and a struct array allgid with fields "file", the GCRSO filename,
%  and nscan, the number of scans in that file.  Note that N in the
%  description above is total scans for all GCRSO files
%
% DISCUSSION
%
%  somewhat ad hoc, probably geo_match should read the GCRSO data
%  directly
%
%  this version is for 60-scan files, is uses a test for file size.
%  When duplicate rid strings (date and start times) are found, the
%  most recent version is used.
%
%  for a single allgeo file the allgid field nscan should always be
%  either 4 or 60, if we are reading all either 4- or 60-scan GCRSO
%  files.  Then for example if nscan = 60 then for scan i, 1<=i<=n,
%  the allgid filename index is floor((i-1)/60)+1
% 
% AUTHOR
%   H. Motteler, 8 May 2012
%

function geo_cat(doy, gdir, odir)

% path to readsdr_rawgeo
addpath /home/motteler/cris/bcast/asl

% default path to geo year
if nargin < 2
  gdir = '/asl/data/cris/sdr60/hdf/2012/';
end

% default output directory
if nargin < 3
  odir = '/home/motteler/cris/data/2012/daily/';  
end

% full path to SDR and geo h5 data
gsrc = fullfile(gdir, doy);

% list all the geo files for this date
glist = dir(fullfile(gsrc, 'GCRSO_npp*.h5'));

% drop anything too small to be a 60-scan file
ix = find([glist.bytes] > 700000);
glist = glist(ix);

if isempty(glist)
  fprintf(1, 'geo_cat: WARNING: no 60-scan files for doy %s\n', doy)
  return
end

% build a list of RIDs
for ix = 1 : length(glist)
  rid = glist(ix).name(17:34);
  rlist{ix} = rid;
end

% choose the last file if there are duplicate RIDs
[rlist, ix] = unique(rlist);
glist = glist(ix);

% loop on geo files
for gi = 1 : length(glist);

  % filename date and start time
  gid = glist(gi).name(11:28);  

  % read the next geo file
  gfile = fullfile(gsrc, glist(gi).name); 
  geo = readsdr_rawgeo(gfile);

  % get scans in this file
  [m, nscan] = size(geo.FORTime);

  % save current filename and nscan 
  allgid(gi).file = glist(gi).name;
  allgid(gi).nscan = nscan;

  % no concatenation at first step
  if gi == 1
    allgeo = geo;
    continue
  end

  % save current geo data
  allgeo.FORTime    = cat(2, allgeo.FORTime,   geo.FORTime);
  allgeo.Height     = cat(3, allgeo.Height,    geo.Height);
  allgeo.Latitude   = cat(3, allgeo.Latitude,  geo.Latitude);
  allgeo.Longitude  = cat(3, allgeo.Longitude, geo.Longitude);
  allgeo.MidTime    = cat(1, allgeo.MidTime,   geo.MidTime);
  allgeo.PadByte1   = cat(1, allgeo.PadByte1,  geo.PadByte1);

  allgeo.QF1_CRISSDRGEO = ...
                      cat(1, allgeo.QF1_CRISSDRGEO, geo.QF1_CRISSDRGEO);

  allgeo.SCAttitude = cat(2, allgeo.SCAttitude, geo.SCAttitude);
  allgeo.SCPosition = cat(2, allgeo.SCPosition, geo.SCPosition);
  allgeo.SCVelocity = cat(2, allgeo.SCVelocity, geo.SCVelocity);

  allgeo.SatelliteAzimuthAngle = ...
                      cat(3, allgeo.SatelliteAzimuthAngle, ...
                                geo.SatelliteAzimuthAngle);

  allgeo.SatelliteRange  = ...
                      cat(3, allgeo.SatelliteRange, ...
                                geo.SatelliteRange);

  allgeo.SatelliteZenithAngle = ...
                      cat(3, allgeo.SatelliteZenithAngle, ...
                                geo.SatelliteZenithAngle);

  allgeo.SolarAzimuthAngle = ...
                      cat(3, allgeo.SolarAzimuthAngle, ...
                                geo.SolarAzimuthAngle);

  allgeo.SolarZenithAngle = ...
                      cat(3, allgeo.SolarZenithAngle, ...
                                geo.SolarZenithAngle);

  allgeo.StartTime  = cat(1, allgeo.StartTime, geo.StartTime);

end

% save the results
dstr = gid(2:9);
save(fullfile(odir, ['allgeo', dstr]), 'allgeo', 'allgid')

