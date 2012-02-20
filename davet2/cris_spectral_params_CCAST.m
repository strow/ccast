
function [user,sensor] = cris_spectral_params(band,wl_laser);

%
% function [user,sensor] = cris_spectral_params(band,wl_laser);
%
% Define various spectral parameters for CrIS FM1.
%
% Inputs:
%     band:        "lw", "mw", or "sw"
%     wl_laser:    wavelength (nm) of the metrology laser
%
% Outputs:
%     user         structure of user grid spectral parameters (based on MOPD of 0.8, 0.4, and 0.2 cm for lw, mw, sw bands)
%     sensor       structure of sensor grid spectral parameters, based on input laser wavelength
%
% DCT, 14 Nov 2011, adapted from cris_params.m and cris_generate_filtScale.m
%


switch upper(band)

case 'LW'

% User grid
user.MOPD = 0.8;
user.Rf = 24;
user.An = 1;
user.N = 864;
user.dx = 2*user.MOPD/user.N;
user.vlaser = user.Rf/user.dx;
user.dv = 1/2/user.MOPD;
user.i1 = 970;
user.i2 = 1833;
user.v = linspace(user.dv*user.i1,user.dv*user.i2,user.N)';
user.output_range = [650 1095];
user.iflip = 106;
user.flipindex = [(user.iflip+1:user.N)' ; (1:user.iflip)'];

% Sensor grid
sensor.vlaser = 1e7/wl_laser;
sensor.Rf = user.Rf;
sensor.N = user.N;
sensor.An = 1;
sensor.dx = sensor.Rf/sensor.vlaser;
sensor.MOPD = sensor.N/2*sensor.dx;
sensor.dv = 1/2/sensor.MOPD;
sensor.i1 = user.i1;
sensor.i2 = user.i2;
sensor.v = linspace(sensor.dv*sensor.i1,sensor.dv*sensor.i2,sensor.N)';
sensor.output_range = [650 1095];
sensor.vb = [sensor.output_range(1)-30 sensor.output_range(1)-5 ...
	     sensor.output_range(2)+5 sensor.output_range(2)+30];


case 'MW'

% User grid
user.MOPD = 0.4;
user.Rf = 20;
user.N = 528;
user.dx = 2*user.MOPD/user.N;
user.vlaser = user.Rf/user.dx;
user.dv = 1/2/user.MOPD;
user.i1 = 948;
user.i2 = 1475;
user.v = linspace(user.dv*user.i1,user.dv*user.i2,user.N)';
user.output_range = [1220 1750];
user.iflip = 420;
user.flipindex = [(user.iflip+1:user.N)' ; (1:user.iflip)'];

% Sensor grid
sensor.vlaser = 1e7/wl_laser;
sensor.Rf = user.Rf;
sensor.N = user.N;
sensor.An = 1;
sensor.dx = sensor.Rf/sensor.vlaser;
sensor.MOPD = sensor.N/2*sensor.dx;
sensor.dv = 1/2/sensor.MOPD;
sensor.i1 = user.i1;
sensor.i2 = user.i2;
sensor.v = linspace(sensor.dv*sensor.i1,sensor.dv*sensor.i2,sensor.N)';
sensor.output_range = user.output_range;
sensor.vb = [sensor.output_range(1)-30 sensor.output_range(1)-5 ...
	     sensor.output_range(2)+5 sensor.output_range(2)+30];

case 'SW'

% User grid
user.MOPD = 0.2;
user.Rf = 26;
user.N = 200;
user.dx = 2*user.MOPD/user.N;
user.vlaser = user.Rf/user.dx;
user.dv = 1/2/user.MOPD;
user.i1 = 848;
user.i2 = 1047;
user.v = linspace(user.dv*user.i1,user.dv*user.i2,user.N)';
user.output_range = [2155 2550];
user.iflip = 48;
user.flipindex = [(user.iflip+1:user.N)' ; (1:user.iflip)'];

% Sensor grid
sensor.vlaser = 1e7/wl_laser;
sensor.Rf = user.Rf;
sensor.N = user.N;
sensor.An = 4;
sensor.dx = sensor.Rf/sensor.vlaser;
sensor.MOPD = sensor.N/2*sensor.dx;
sensor.dv = 1/2/sensor.MOPD;
sensor.i1 = user.i1;
sensor.i2 = user.i2;
sensor.v = linspace(sensor.dv*sensor.i1,sensor.dv*sensor.i2,sensor.N)';
sensor.output_range = user.output_range;
sensor.vb = [sensor.output_range(1)-30 sensor.output_range(1)-5 ...
	     sensor.output_range(2)+5 sensor.output_range(2)+30];

otherwise

disp('what are you doing?')

end



%filtScale.v_laser = 1e7/filtScale.wl_laser;
%filtScale.bw = filtScale.v_laser / filtScale.Rf;                        % bandwidth (1/cm)
%filtScale.dx = filtScale.Rf / filtScale.v_laser;                        % IFG sampling step (cm)
%filtScale.X = filtScale.dx * filtScale.P/2;                             % Max OPD for number of retained IFG points
%filtScale.dv = 1/(2*filtScale.X);                                       % wavenumber step (1/cm)
%filtScale.v1 = filtScale.bw*(filtScale.An) + filtScale.dv*iflip;        % first wavenumber (1/cm)
%filtScale.v2 = filtScale.bw*(filtScale.An + 1) + filtScale.dv*iflip - filtScale.dv;               % last wavenumber (1/cm)
%filtScale.v = linspace(filtScale.v1,filtScale.v2,filtScale.P)';      % wavenumbers (1/cm)                                             
%filtScale.vv = filtScale.dv*(iflip:iflip+filtScale.P-1)' + filtScale.bw;        % wavenumber scale
%filtScale.x = [linspace(-filtScale.X,-filtScale.dx,filtScale.P/2)' ; linspace(0,filtScale.X-filtScale.dx,filtScale.P/2)'];
%filtScale.iflip = iflip;
%filtScale.index = index;

