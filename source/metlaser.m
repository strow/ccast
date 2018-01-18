
function [wlaser, mtime] = metlaser(NeonCal, opts);

%  Input:  An MIT "d1.packet.NeonCal" structure
%  Output: Metrology laser wavelength
%
%  Uncertain if mtime should be returned, or a "raw" time
%
% Created 8-Dec-2011 by L. Strow
%
% Fixed Neon wavelength, LLS Mn value
% neonWL       =  703.44835;

% default Neon wavelength from eng
neonWL = NeonCal.NeonGasWavelength;

% option to override eng Neon value
if nargin == 2 && isfield(opts, 'neonWL')
% fprintf(1, 'metlaser: setting neonWL from opts\n')
  neonWL = opts.neonWL;
end

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
wlaser                      = neonWL * InterpolatedNeonFringeCount ./ NeonCal.LaserFringeCount;
wlaser                      = mean(wlaser)/2;

mtime                       = datenum(0,0,NeonCal.TimeStamp.Days+dstart_1958,0,0,NeonCal.TimeStamp.msec/1000);

return



