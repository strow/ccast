%
% accumulate a day's worth of geo data
% 

% path to readsdr_rawgeo
addpath /home/motteler/cris/rdr2spec5/asl

% path to SDR and geo h5 data
gsrc = '/asl/data/cris/sdr60/hdf/2012/093';

% output directory
odir = '.';

% list all the geo files for this date
glist = dir(sprintf('%s/GCRSO_npp*.h5', gsrc));
ngfile = length(glist);

% loop on geo files
for gi = 1 : ngfile

  % filename date and start time
  gid = glist(gi).name(11:28);  

  % read the next geo file
  gfile = [gsrc,'/',glist(gi).name];
  geo = readsdr_rawgeo(gfile);

  % no concatenation at first step
  if gi == 1
    allgeo = geo;
    continue
  end

%                FORTime: [30x60 int64]
%                 Height: [9x30x60 single]
%               Latitude: [9x30x60 single]
%              Longitude: [9x30x60 single]
%                MidTime: [60x1 int64]
%               PadByte1: [60x1 uint8]
%         QF1_CRISSDRGEO: [60x1 uint8]
%             SCAttitude: [3x60 single]
%             SCPosition: [3x60 single]
%             SCVelocity: [3x60 single]
%  SatelliteAzimuthAngle: [9x30x60 single]
%         SatelliteRange: [9x30x60 single]
%   SatelliteZenithAngle: [9x30x60 single]
%      SolarAzimuthAngle: [9x30x60 single]
%       SolarZenithAngle: [9x30x60 single]
%              StartTime: [60x1 int64]
%
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
save([odir, '/allgeo', dstr], 'allgeo')

