% 
% NAME
%   geo_daily - save a day's worth of GCRSO data in a mat file
%
% SYNOPSIS
%   orbst2 = geo_daily(doy, gdir, odir, orbst1)
%
% INPUTS
%   doy    - directory of GCRSO files, typically doy
%   gdir   - path to the doy directory, typically year
%   odir   - output directory, typically by year
%   orbst1 - orbit start time from previous day
%
% OUTPUT
%   orbst2 - start time for last orbit of the day
%
% The primary output is a matfile odir/allgeoYYYYMMDD.mat containing
% a struct allgeo with the GCRSO data fields
%
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
% selected GCRSO attribute (and attribute-derived) fields
%
%          Asc_Desc_Flag: [N x 1 double]
%           Orbit_Number: [N x 1 double]
%             Granule_ID: [N x 16 char]
%       Orbit_Start_Time: [N x 1 double]
%
% and locally defined fields
%
%                sdr_gid: [N x 18 char]
%                sdr_ind: [N x 1 double]
%
% N is total scans for all GCRSO files read, typically a day's
% worth of data.
%
% DISCUSSION
%
%  somewhat ad hoc, probably geo_match should read the GCRSO data
%  directly
%
%  this version includes a size test that drops files too small to
%  be 60-scan files.  This can be modified or dropped to work with
%  4-scan files.  to work with 4-scan files drop the size test and
%  pass ndset = 1 in to read_GCRSO
% 
%  When duplicate rid strings (date and start times) are found, the
%  newest version is used.
%
%
% AUTHOR
%   H. Motteler, 8 May 2012
%

function orbst2 = geo_daily(doy, gdir, odir, orbst1)

% default orbit start time is undefined
if nargin < 4
  orbst1 = NaN;
end

% orbit number is initially undefined
orbnum = NaN;
orbst2 = NaN;

% full path to SDR and geo h5 data
gsrc = fullfile(gdir, doy);

% create the output path, if needed
unix(['mkdir -p ', odir]);

% list all the geo files for this date
glist = dir(fullfile(gsrc, 'GCRSO_npp*.h5'));
n1 = length(glist);

% drop anything too small to be a 60-scan file
ix = find([glist.bytes] > 400000);
glist = glist(ix);
n2 = length(glist);
if n2 < n1
  fprintf(1, 'geo_daily: WARNING: %d short file(s)\n', n1 - n2)
end

if isempty(glist)
  fprintf(1, 'geo_daily: WARNING: no 60-scan files for doy %s\n', doy)
  return
end

% build a list of RIDs
for ix = 1 : length(glist)
  rid = glist(ix).name(11:28);
  rlist{ix} = rid;
end

% choose the last file if there are duplicate RIDs
[rlist, ix] = unique(rlist);
glist = glist(ix);

% loop on remaining geo files
for gi = 1 : length(glist);

  % filename date and start time
  gid = glist(gi).name(11:28);  

  % read the next geo file
  gfile = fullfile(gsrc, glist(gi).name); 
  try 
    [geo, agatt, attr4] = read_GCRSO(gfile);
  catch
    fprintf(1, 'geo_daily: error reading %s\n', gfile)
    fprintf(1, 'continuing with the next file...\n')
    continue
  end

  % get scans in this file
  [m, nscan] = size(geo.FORTime);

  % organize selected attributes by scans
  ngran = length(attr4);
  t1 = ones(nscan, 1) * NaN;   % Asc_Desc_Flag
  t2 = ones(nscan, 1) * NaN;   % Orbit_Number
  t3 = ones(nscan, 16) * NaN;  % Granule_ID
  t4 = ones(nscan, 1) * NaN;   % Orbit_Start_Time

  % loop on granules
  for j = 1 : ngran

    % update orbit number and start time on changes
    t0 = double(attr4(j).N_Beginning_Orbit_Number);
    if t0 ~= orbnum
      orbnum = t0;
      orbst1 = attr4(j).N_Beginning_Time_IET;
    end

    % copy attributes to the 4 scans of this granule
    for k = 1 : 4
      i = (j-1) * 4 + k;  
      t1(i) = double(attr4(j).Ascending_Descending_Indicator);
      t2(i) = double(attr4(j).N_Beginning_Orbit_Number);
      t3(i,:) = double(attr4(j).N_Granule_ID{1});
      t4(i) = orbst1;
    end
  end
  if i ~= nscan
    error('attribute count mismatch')
  end

  % no concatenation at first step
  if gi == 1
    % copy first geo record
    allgeo = geo;

    % add selected attribute fields
    allgeo.Asc_Desc_Flag = t1;
    allgeo.Orbit_Number = t2;
    allgeo.Granule_ID = char(t3);
    allgeo.Orbit_Start_Time = t4;

    % add file id string gid and scan index   
    allgeo.sdr_gid = char(ones(nscan,1) * double(gid));
    allgeo.sdr_ind = (1:nscan)';

    continue
  end

  % concatenate current geo data
  allgeo.FORTime    = cat(2, allgeo.FORTime,   geo.FORTime);
  allgeo.Height     = cat(3, allgeo.Height,    geo.Height);
  allgeo.Latitude   = cat(3, allgeo.Latitude,  geo.Latitude);
  allgeo.Longitude  = cat(3, allgeo.Longitude, geo.Longitude);
  allgeo.MidTime    = cat(1, allgeo.MidTime,   geo.MidTime);
  allgeo.PadByte1   = cat(1, allgeo.PadByte1,  geo.PadByte1);
  allgeo.QF1_CRISSDRGEO ...
     = cat(1, allgeo.QF1_CRISSDRGEO, geo.QF1_CRISSDRGEO);
  allgeo.SCAttitude = cat(2, allgeo.SCAttitude, geo.SCAttitude);
  allgeo.SCPosition = cat(2, allgeo.SCPosition, geo.SCPosition);
  allgeo.SCVelocity = cat(2, allgeo.SCVelocity, geo.SCVelocity);
  allgeo.SatelliteAzimuthAngle ...
     = cat(3, allgeo.SatelliteAzimuthAngle, geo.SatelliteAzimuthAngle);
  allgeo.SatelliteRange ...
     = cat(3, allgeo.SatelliteRange, geo.SatelliteRange);
  allgeo.SatelliteZenithAngle ...
     = cat(3, allgeo.SatelliteZenithAngle, geo.SatelliteZenithAngle);
  allgeo.SolarAzimuthAngle ...
     = cat(3, allgeo.SolarAzimuthAngle, geo.SolarAzimuthAngle);
  allgeo.SolarZenithAngle ...
     = cat(3, allgeo.SolarZenithAngle, geo.SolarZenithAngle);
  allgeo.StartTime  = cat(1, allgeo.StartTime, geo.StartTime);

  % add selected attributes
  allgeo.Asc_Desc_Flag    = cat(1, allgeo.Asc_Desc_Flag, t1);
  allgeo.Orbit_Number     = cat(1, allgeo.Orbit_Number, t2);
  allgeo.Granule_ID       = cat(1, allgeo.Granule_ID, char(t3));
  allgeo.Orbit_Start_Time = cat(1, allgeo.Orbit_Start_Time, t4);

  % add file date string gid and scan index   
  stmp = char(ones(nscan,1) * double(gid));
  allgeo.sdr_gid = cat(1, allgeo.sdr_gid, stmp);
  allgeo.sdr_ind = cat(1, allgeo.sdr_ind, (1:nscan)');

end

% save the results
dstr = gid(2:9);
save(fullfile(odir, ['allgeo', dstr]), 'allgeo')

% return last orbit start time for the next day
orbst2 = orbst1;

