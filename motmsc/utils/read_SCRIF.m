%
% NAME
%   read_SCRIS - read CrIS SCRIS SDR data and attributes
%
% SYNOPSIS
%   [sdr, agatt, attr4] = read_SCRIS(gfile)
%
% INPUT
%   gfile    - h5 SCRIS (CrIS SDR) filename
%
% OUTPUTS
%   sdr      - struct with SCRIS data fields as arrays
%   agatt    - aggregate attributes for the entire file
%   attr4    - attributes for each 4-scan group
%
% DISCUSSION
%   if agatt or attr4 are not needed the function is faster if they
%   are dropped from the output parameter list.
%
% AUTHOR
%   H. Motteler, 12 Jan 2018
%

function [sdr, agatt, attr4] = read_SCRIS(gfile)

% ---------------
% return sdr data
% ---------------
sdr = struct;
dpath = '/All_Data/CrIS-FS-SDR_All';

dname{1} = 'DS_SpectralStability';
dname{2} = 'DS_Symmetry';
dname{3} = 'DS_WindowSize';
dname{4} = 'ES_ImaginaryLW';
dname{5} = 'ES_ImaginaryMW';
dname{6} = 'ES_ImaginarySW';
dname{7} = 'ES_NEdNLW';
dname{8} = 'ES_NEdNMW';
dname{9} = 'ES_NEdNSW';
dname{10} = 'ES_RDRImpulseNoise';
dname{11} = 'ES_RealLW';
dname{12} = 'ES_RealMW';
dname{13} = 'ES_RealSW';
dname{14} = 'ES_ZPDAmplitude';
dname{15} = 'ES_ZPDFringeCount';
dname{16} = 'ICT_SpectralStability';
dname{17} = 'ICT_TemperatureConsistency';
dname{18} = 'ICT_TemperatureStability';
dname{19} = 'ICT_WindowSize';
dname{20} = 'ES_NEdNSW';
dname{21} = 'ES_RDRImpulseNoise';
dname{22} = 'ES_RealLW';
dname{23} = 'ES_RealMW';
dname{24} = 'ES_RealSW';
dname{25} = 'ES_ZPDAmplitude';
dname{26} = 'ES_ZPDFringeCount';
dname{27} = 'ICT_SpectralStability';
dname{28} = 'ICT_TemperatureConsistency';
dname{29} = 'ICT_TemperatureStability';
dname{30} = 'ICT_WindowSize';
dname{31} = 'MeasuredLaserWavelength';
dname{32} = 'MonitoredLaserWavelength';
dname{33} = 'NumberOfValidPRTTemps';
dname{34} = 'QF1_SCAN_CRISSDR';
dname{35} = 'QF2_CRISSDR';
dname{36} = 'QF3_CRISSDR';
dname{37} = 'QF4_CRISSDR';
dname{38} = 'ResamplingLaserWavelength';
dname{39} = 'SDRFringeCount';
nfields = 39;

% loop on fields, do the read
for ix = 1 : nfields
  dval = h5read(gfile, [dpath, '/', dname{ix}]);
  sdr = setfield(sdr, dname{ix}, dval);
end

% quit if we're done
if nargout == 1, return, end

% ---------------------------
% return aggregate attributes
% ---------------------------
agatt = struct;
apath = '/Data_Products/CrIS-FS-SDR/CrIS-FS-SDR_Aggr';

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
  agatt = setfield(agatt, aname{ix}, aval);
end

% quit if we're done
if nargout == 2, return, end

% ------------------------
% return 4-scan attributes
% ------------------------
attr4 = struct;
apath = '/Data_Products/CrIS-FS-SDR';

% datasets in time order
dset{1}  = 'CrIS-FS-SDR_Gran_0';
dset{2}  = 'CrIS-FS-SDR_Gran_1';
dset{3}  = 'CrIS-FS-SDR_Gran_2';
dset{4}  = 'CrIS-FS-SDR_Gran_3';
dset{5}  = 'CrIS-FS-SDR_Gran_4';
dset{6}  = 'CrIS-FS-SDR_Gran_5';
dset{7}  = 'CrIS-FS-SDR_Gran_6';
dset{8}  = 'CrIS-FS-SDR_Gran_7';
dset{9}  = 'CrIS-FS-SDR_Gran_8';
dset{10} = 'CrIS-FS-SDR_Gran_9';
dset{11} = 'CrIS-FS-SDR_Gran_10';
dset{12} = 'CrIS-FS-SDR_Gran_11';
dset{13} = 'CrIS-FS-SDR_Gran_12';
dset{14} = 'CrIS-FS-SDR_Gran_13';
dset{15} = 'CrIS-FS-SDR_Gran_14';

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

% get the number of 4-scan granules
ndset = agatt.AggregateNumberGranules;

% loop on datasets and fields, do the reads
for j = 1 : ndset
  for i = 1 : nfields
    aval = h5readatt(gfile, [apath, '/', dset{j}], aname{i});
    % want the effect of  attr4(j).bname{i} = aval;
    attr4 = setfield(attr4, {j}, bname{i}, aval);
  end
end

