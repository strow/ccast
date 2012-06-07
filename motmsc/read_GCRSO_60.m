%
% NAME
%   read_GCRSO_60 - read a CrIS GCRSO 60-scan geo file
%
% SYNOPSIS
%   [geo, attr60, attr4] = read_GCRSO_60(gfile)
%
% INPUT
%   gfile    - h5 GCRSO (CrIS geo) filename
%
% OUTPUTS
%   geo      - struct with GCRSO data fields as arrays
%   attr60   - aggregate attributes for the 60-scan/15 granule file
%   attr4    - attributes for each 4-scan granule, as a struct array
%
% DISCUSSION
%   returns GCRSO data and optionally, attributes.  assumes a 60-
%   scan file with 15 4-scan "granules".  All the h5 field names and
%   paths are hard-coded to avoid calling h5info, which is very slow,
%   but this means the function will crash with wonky data.
% 
%   if attr4 or attr60 are not needed, the function is much faster
%   if they are not included in the output parameter list.  attr4 is
%   particularly slow because it loops on attributes and h5 groups.
%
%   the geo output is identical with Scott's readsdr_rawgeo.m reader
%
% AUTHOR
%   H. Motteler, 22 May 2012
%

function [geo, attr60, attr4] = read_GCRSO_60(gfile)

% ---------------
% return geo data
% ---------------
geo = struct;
dpath = '/All_Data/CrIS-SDR-GEO_All';

dname{1} = 'FORTime';
dname{2} = 'Height';
dname{3} = 'Latitude';
dname{4} = 'Longitude';
dname{5} = 'MidTime';
dname{6} = 'PadByte1';
dname{7} = 'QF1_CRISSDRGEO';
dname{8} = 'SCAttitude';
dname{9} = 'SCPosition';
dname{10} = 'SCVelocity';
dname{11} = 'SatelliteAzimuthAngle';
dname{12} = 'SatelliteRange';
dname{13} = 'SatelliteZenithAngle';
dname{14} = 'SolarAzimuthAngle';
dname{15} = 'SolarZenithAngle';
dname{16} = 'StartTime';
nfields = 16;

% loop on fields, do the read
for ix = 1 : nfields
  dval = h5read(gfile, [dpath, '/', dname{ix}]);
  geo = setfield(geo, dname{ix}, dval);
end

% quit if we're done
if nargout == 1, return, end

% ---------------------------
% return aggregate attributes
% ---------------------------
attr60 = struct;
apath = '/Data_Products/CrIS-SDR-GEO/CrIS-SDR-GEO_Aggr';

% selected attributes
aname{1} = 'AggregateBeginningDate';
aname{2} = 'AggregateBeginningGranuleID';
aname{3} = 'AggregateBeginningOrbitNumber';
aname{4} = 'AggregateBeginningTime';
aname{5} = 'AggregateEndingDate';
aname{6} = 'AggregateEndingGranuleID';
aname{7} = 'AggregateEndingOrbitNumber';
aname{8} = 'AggregateEndingTime';
aname{9} = 'AggregateNumberGranules';
nfields = 9;

% loop on fields, do the read
for ix = 1 : nfields
  aval = h5readatt(gfile, apath, aname{ix});
  attr60 = setfield(attr60, aname{ix}, aval);
end

% quit if we're done
if nargout == 2, return, end

% ------------------------
% return 4-scan attributes
% ------------------------
attr4 = struct;
apath = '/Data_Products/CrIS-SDR-GEO';

% datasets in time order
dset{1}  = 'CrIS-SDR-GEO_Gran_0';
dset{2}  = 'CrIS-SDR-GEO_Gran_1';
dset{3}  = 'CrIS-SDR-GEO_Gran_2';
dset{4}  = 'CrIS-SDR-GEO_Gran_3';
dset{5}  = 'CrIS-SDR-GEO_Gran_4';
dset{6}  = 'CrIS-SDR-GEO_Gran_5';
dset{7}  = 'CrIS-SDR-GEO_Gran_6';
dset{8}  = 'CrIS-SDR-GEO_Gran_7';
dset{9}  = 'CrIS-SDR-GEO_Gran_8';
dset{10} = 'CrIS-SDR-GEO_Gran_9';
dset{11} = 'CrIS-SDR-GEO_Gran_10';
dset{12} = 'CrIS-SDR-GEO_Gran_11';
dset{13} = 'CrIS-SDR-GEO_Gran_12';
dset{14} = 'CrIS-SDR-GEO_Gran_13';
dset{15} = 'CrIS-SDR-GEO_Gran_14';
ndset = 15;

% selected attributes
aname{1} = 'Ascending/Descending_Indicator';
aname{2} = 'Beginning_Date';
aname{3} = 'Beginning_Time';
aname{4} = 'Ending_Date';
aname{5} = 'Ending_Time';
aname{6} = 'N_Beginning_Orbit_Number';
aname{7} = 'N_Beginning_Time_IET';
aname{8} = 'N_Ending_Time_IET';
aname{9} = 'N_Granule_ID';
aname{10} = 'N_Nadir_Latitude_Max';
aname{11} = 'N_Nadir_Latitude_Min';
aname{12} = 'N_Nadir_Longitude_Max';
aname{13} = 'N_Nadir_Longitude_Min';
aname{14} = 'North_Bounding_Coordinate';
aname{15} = 'South_Bounding_Coordinate';
aname{16} = 'East_Bounding_Coordinate';
aname{17} = 'West_Bounding_Coordinate';
aname{18} = 'N_Spacecraft_Maneuver';
aname{19} = 'N_Number_Of_Scans';
nfields = 19;

% fix any non-matlab compatible field names
bname = aname;
bname{1} = 'Ascending_Descending_Indicator';

% loop on datasets and fields, do the reads
for j = 1 : ndset
  for i = 1 : nfields
    aval = h5readatt(gfile, [apath, '/', dset{j}], aname{i});
    % want the effect of  attr4(j).bname{i} = aval;
    % eval(sprintf('attr4(%d).%s = aval;', j, bname{i}));
    attr4 = setfield(attr4, {j}, bname{i}, aval);
  end
end

