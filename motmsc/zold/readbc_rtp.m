%
% NAME
%   readbc_rtp - translate bcast SDR data to RTP profiles
%
% SYNOPSIS
%   [prof, pattr] = readbc_rtp(bfile);
%
% INPUTS
%   bfile  - bcast SDR mat file
%
% OUTPUTS
%   prof   - RTP v201 profile struct
%   pattr  - RTP attributes in a cell array
%
% DISCUSSION
%   under development, big chunks taken from readsdr_rtp
%
% AUTHOR
%  H. Motteler, 20 Aug 2012
%

function [prof, pattr] = readbc_rtp(bfile);

% seconds between 1 Jan 1958 and 1 Jan 2000
tdif = 15340 * 24 * 3600;

% IDPS SDR channel frequencies
wn_lw = linspace(650-0.625*2,1095+0.625*2,717)';
wn_mw = linspace(1210-1.25*2,1750+1.25*2,437)';
wn_sw = linspace(2155-2.50*2,2550+2.50*2,163)';

nchanLW = length(wn_lw);
nchanMW = length(wn_mw);
nchanSW = length(wn_sw);
nchan = nchanLW + nchanMW + nchanSW;

if exist(bfile) ~= 2
  bfile
  error('bcast SDR mat file not found')
end

% load bcast SDR data
load(bfile)

% sanity check for bcast SDR fields
if exist ('scTime') ~= 1
  bfile
  error('invalid bcast SDR mat file')
end

% sanity and existance check for geo fields
if isnan(geo.FORTime(15,2))
  error('invalid or missing geo data')
end

% get data sizes
[m, nscan] = size(scTime);
nobs = 9 * 30 * nscan;

% get IDPS indices into bcast spectra
iLW = interp1(vLW, (1:length(vLW))', wn_lw, 'nearest');
iMW = interp1(vMW, (1:length(vMW))', wn_mw, 'nearest');
iSW = interp1(vSW, (1:length(vSW))', wn_sw, 'nearest');

% copy bcast geo values to the prof struct
prof = struct;
prof.rlat = single(geo.Latitude(:)');
prof.rlon = single(geo.Longitude(:)');
prof.rtime = reshape(ones(9,1) * (geo.FORTime(:)' * 1e-6 - tdif), 1, nobs);
prof.satzen = single(geo.SatelliteZenithAngle(:)');
prof.satazi = single(geo.SatelliteAzimuthAngle(:)');
prof.solzen = single(geo.SolarZenithAngle(:)');
prof.solazi = single(geo.SolarAzimuthAngle(:)');
prof.zobs = single(geo.Height(:)');

% locally assigned values for the prof struct
prof.pobs = zeros(1,nobs,'single');
prof.upwell = ones(1,nobs,'int32');

iobs = 1:nobs;
prof.atrack = int32( 1 + floor((iobs-1)/270) );
prof.xtrack = int32( 1 + mod(floor((iobs-1)/9),30) );
prof.ifov = int32( 1 + mod(iobs-1,9) );

% copy bcast radiance values to the prof struct
prof.robs1 = zeros(nchan, nobs, 'single');

ic = 1:nchanLW;
prof.robs1(ic,:) = single(reshape(rLW(iLW,:,:,:), nchanLW, nobs));

ic = nchanLW + (1:nchanMW);
prof.robs1(ic,:) = single(reshape(rMW(iMW,:,:,:), nchanMW, nobs));

ic = nchanLW + nchanMW + (1:nchanSW);
prof.robs1(ic,:) = single(reshape(rSW(iSW,:,:,:), nchanSW, nobs));

prof.robsqual = zeros(1, nobs, 'single');

% assign the prof struct udefs
prof.udef = zeros(20, nobs, 'single');
prof.iudef = zeros(10, nobs, 'int32');

% iudef 3 is granule ID as an int32
t1 = str2double(cellstr(geo.Granule_ID(:,4:16)))';
t2 = int32(ones(270,1) * t1);
prof.iudef(3,:) = t2(:)';

% iudef 4 is ascending/descending flag
t1 = geo.Asc_Desc_Flag';
t2 = int32(ones(270,1) * t1);
prof.iudef(4,:) = t2(:)';

% iudef 5 is orbit number 
t1 = geo.Orbit_Number';
t2 = int32(ones(270,1) * t1);
prof.iudef(5,:) = t2(:)';

% Interpolate X,Y,Z at MidTime to rtime
xyz = geo.SCPosition; % [3 x 4*n]
mtime = double(geo.MidTime)*1E-6 - tdif; % [1 x 4*n]
isub = prof.rtime > 0;
msel = [logical(1); diff(mtime) > 0];
prof.udef(10,isub) = interp1(mtime(msel),xyz(1,msel),prof.rtime(isub),'linear','extrap');
prof.udef(11,isub) = interp1(mtime(msel),xyz(2,msel),prof.rtime(isub),'linear','extrap');
prof.udef(12,isub) = interp1(mtime(msel),xyz(3,msel),prof.rtime(isub),'linear','extrap');

% prof.iudef( 8,:) = QAbitsLW;
% prof.iudef( 9,:) = QAbitsMW;
% prof.iudef(10,:) = QAbitsSW;

% attributes borrowed from readsdr_rtp
pattr = {{'profiles' 'rtime' 'seconds since 0z 1 Jan 2000'}, ...
         {'profiles' 'iudef(3,:)' 'Granule ID {granid}'}, ...
         {'profiles' 'iudef(4,:)' 'Descending Indicator {descending_ind}'}, ...
         {'profiles' 'iudef(5,:)' 'Beginning Orbit Number {orbit_num}'}, ...
         {'profiles' 'iudef(8,:)' 'longwave QA bits {QAbitsLW}'}, ...
         {'profiles' 'iudef(9,:)' 'mediumwave QA bits {QAbitsMW}'}, ...
         {'profiles' 'iudef(10,:)' 'shortwave QA bits {QAbitsSW}'}, ...
         {'profiles' 'udef(10,:)' 'spacecraft X coordinate {X}'}, ...
         {'profiles' 'udef(11,:)' 'spacecraft Y coordinate {Y}'}, ...
         {'profiles' 'udef(12,:)' 'spacecraft Z coordinate {Z}'}, ...
        };

