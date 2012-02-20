function [metlaser,mtime] = cris_metlaser_CCAST(NeonCal);

% Created 8-Dec-2011 by L. Strow

%  Input:  An MIT "d1.packet.NeonCal" structure
%  Output: Metrology laser wavelength
%
%  Uncertain if mtime should be returned, or a "raw" time

% Fixed Neon wavelength, LLS Mn value
neonl       =  703.44835;

% Date start time
dstart_1958 = datenum(1958,1,1,0,0,0);

n = NeonCal.NbCalibrationSweeps;  % Always == 30
n = 1:n;
NeonFringeCount             = NeonCal.NeonFringeCount(n);
NeonStartingPartialCount    = NeonCal.NeonStartingPartialCount(n); 
NeonEndingPartialCount      = NeonCal.NeonEndingPartialCount(n);
NeonStartingCount           = NeonCal.NeonStartingCount(n);
NeonEndingCount             = NeonCal.NeonEndingCount(n);
InterpolatedNeonFringeCount = NeonFringeCount + (NeonStartingPartialCount ./ NeonStartingCount) - (NeonEndingPartialCount ./ NeonEndingCount) ;
metlaser                    = neonl * InterpolatedNeonFringeCount ./ NeonCal.LaserFringeCount;
metlaser                    = mean(metlaser)/2;

mtime                       = datenum(0,0,NeonCal.TimeStamp.Days+dstart_1958,0,0,NeonCal.TimeStamp.msec/1000);

return



