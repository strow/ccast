 
function [user,sensor] = spectral_params(band,wl_laser);

%
% function [user,sensor] = spectral_params(band,wl_laser);
%
% Define various spectral parameters for CrIS FM1.
%
% Inputs:
%     band:        "lw", "mw", or "sw"
%     wl_laser:    effective on-axis wavelength of the metrology laser (nm)
%
% Outputs:
%     user         Structure of user grid spectral parameters (based on MOPD of 
%                     0.8, 0.4, and 0.2 cm for lw, mw, sw bands)
%     sensor       Structure of sensor grid spectral parameters, based on input 
%                     laser wavelength (and other internally set parameters).
%
% DCT, 14 Nov 2011, Adapted from cris_params.m and cris_generate_filtScale.m
% DCT, 08-Dec-2011, Switched from ideal FPA parameters to Larrabee's values based 
%                     on gas cell data analysis
% DCT, 09-Dec-2011, Made FOV dependent sensor params ... defining "on_axis" and FOV 
%                     dependent fields.
% DCT, 11-Dec-2011, Off-axis parameter scale factor is now centroid of off-axis 
%                     weights; previously was cos(FOVangle).  And including arrays 
%                     of emperical OPD scale factors.
% LLS, 05-Feb-2011, Mid-wave sensor.FOVangle fixed due to a sign error in the y-offset.  
%                   See CCAST_dct20111208/lstrow_ils_params_20111207.m, line 18 should be -531
switch upper(band)

case 'LW'

  %%%%%%%%%%%%%%%%%%
  %% LONGWAVE     %%
  %%%%%%%%%%%%%%%%%%

  %% User grid
  user.MOPD = 0.8;
  user.Rf = 24;
  user.N = 864;
  user.dx = 2*user.MOPD/user.N;
  user.vlaser = user.Rf/user.dx;
  user.dv = 1/2/user.MOPD;
  user.i1 = 970;
  user.i2 = 1833;
  user.output_range = [650 1095];
  user.iflip = 106;

  %% Sensor grid
  % From Larrabee's gas cell analysis (see lstrow_ils_params_20111207.m)
  % ORIG sensor.FOVangle = [0.02688353  0.01937335  0.02760812  0.01869841  0.00051127  0.01966839  0.02670730  0.01908645  0.02746328];
  % New sensor.FOVangle based on Feb 13 data.
  sensor.FOVangle = [0.02688708 0.01931040 0.02745719 0.01872599 0.00039304 0.01946177 0.02669410 0.01898521 0.02720102];
  sensor.FOVradius = [0.00840300  0.00840300  0.00840300  0.00840300  0.00840300  0.00840300  0.00840300  0.00840300  0.00840300];
  % ideal FPA FOV off-axis angles and radius
  %sensor.FOVangle = [0.0272 0.0192 0.0272 0.0192 0       0.0192 0.0272 0.0192 0.0272];
  %sensor.FOVradius = ones(9,1)*7/833;

  % Emperical OPD scale factors for each FOV.  These multiply the OPDs (not the wavenumbers)
  sensor.emperical_scale_fac = [1 1 1 1 1 1 1 1 1];

case 'MW'

  %%%%%%%%%%%%%%%%%%
  %% MIDWAVE      %%
  %%%%%%%%%%%%%%%%%%

  %% User grid
  user.MOPD = 0.4;
  user.Rf = 20;
  user.N = 528;
  user.dx = 2*user.MOPD/user.N;
  user.vlaser = user.Rf/user.dx;
  user.dv = 1/2/user.MOPD;
  user.i1 = 948;
  user.i2 = 1475;
  user.output_range = [1220 1750];
  user.iflip = 420;

  %% Sensor grid
  % From Larrabee's gas cell analysis (see lstrow_ils_params_20111207.m)

  % Original value below incorrect due to a sign error in y-offset, LLS
  % sensor.FOVangle = [0.02771102  0.01946025  0.02685333  0.01978328  0.00054148  0.01860630  0.02751085  0.01911938  0.02668295];
  %ORIG  sensor.FOVangle = [0.02696221  0.01946025  0.02760214  0.01872130  0.00054148  0.01966829  0.02675790  0.01911938  0.02743591];
  % New sensor.FOVangle based on Feb 13 data.
  sensor.FOVangle = [0.02692817  0.01932544  0.02744433  0.01877022  0.00041968  0.01943880  0.02670933  0.01897094  0.02714583];
  sensor.FOVradius =[0.00840300  0.00840300  0.00840300  0.00840300  0.00840300  0.00840300  0.00840300  0.00840300  0.00840300];
  % Ideal:
  %sensor.FOVangle = [0.0272 0.0192 0.0272 0.0192 0       0.0192 0.0272 0.0192 0.0272];
  %sensor.FOVradius = ones(9,1)*7/833;

  % Emperical OPD scale factors for each FOV.  These multiply the OPDs (not the wavenumbers)
  sensor.emperical_scale_fac = [1 1 1 1 1 1 1 1 1];

case 'SW'

  %%%%%%%%%%%%%%%%%%
  %% SHORTWAVE    %%
  %%%%%%%%%%%%%%%%%%

  %% User grid
  user.MOPD = 0.2;
  user.Rf = 26;
  user.N = 200;
  user.dx = 2*user.MOPD/user.N;
  user.vlaser = user.Rf/user.dx;
  user.dv = 1/2/user.MOPD;
  user.i1 = 848;
  user.i2 = 1047;
  user.output_range = [2155 2550];
  user.iflip = 48;

  %% Sensor grid
  % From Larrabee's gas cell analysis (see lstrow_ils_params_20111207.m)
  %ORIG: sensor.FOVangle = [0.02703163  0.01942358  0.02755713  0.01887655  0.00039983  0.01959553  0.02682600  0.01913164  0.02736818];
  % New sensor.FOVangle based on Feb 13 data.
  sensor.FOVangle = [0.02687735 0.01928389 0.02737835 0.01875077 0.00034464 0.01935134 0.02671876 0.01895481 0.02709675];
  sensor.FOVradius =[0.00840300  0.00840300  0.00840300  0.00840300  0.00840300  0.00840300  0.00840300  0.00840300  0.00840300];
  % Ideal
  %sensor.FOVangle = [0.0272 0.0192 0.0272 0.0192 0       0.0192 0.0272 0.0192 0.0272];
  %sensor.FOVradius = ones(9,1)*7/833;

  % Emperical OPD scale factors for each FOV.  These multiply the OPDs (not the wavenumbers)
  sensor.emperical_scale_fac = [1 1 1 1 1 1 1 1 1];

end


%% Compute/set rest of parameters from what's been defined above:

%% User:
user.band = band;
user.v = linspace(user.dv*user.i1,user.dv*user.i2,user.N)';
user.flipindex = [(user.iflip+1:user.N)' ; (1:user.iflip)'];

%% Sensor:
sensor.band = band;
sensor.vlaser = 1e7/wl_laser;
sensor.Rf = user.Rf;
sensor.N = user.N;
sensor.dx_onaxis = sensor.Rf/sensor.vlaser;
sensor.i1 = user.i1;
sensor.i2 = user.i2;
sensor.output_range = user.output_range;
sensor.vb = [sensor.output_range(1)-30 sensor.output_range(1)-5 ...
	     sensor.output_range(2)+5 sensor.output_range(2)+30];
sensor.iflip = user.iflip;
sensor.flipindex = user.flipindex;

%% "On-axis sensor" parameters:
sensor.MOPD_onaxis = sensor.N/2*sensor.dx_onaxis;
sensor.dv_onaxis = 1/2/sensor.MOPD_onaxis;
sensor.v_onaxis = linspace(sensor.dv_onaxis*sensor.i1,sensor.dv_onaxis*sensor.i2,sensor.N)';

%% FOV dependent parameters
for iFov = 1:9

  % Off-axis weights
  [nu_over_nu0,weight] = offAxisWeights(sensor.FOVangle(iFov),sensor.FOVradius(iFov));
  % And centroid of weights.  For small FOVradius this is very close to cos(FOVangle).
  sensor.off_axis_scale_factor(iFov) = sum(weight.*nu_over_nu0);

  % Use the off-axis scale factor to scale the OPDs, and corresponding params
  dx = sensor.dx_onaxis * sensor.off_axis_scale_factor(iFov);
  MOPD = sensor.N/2*dx;
  dv = 1/2/MOPD;
  sensor.v_offaxis(:,iFov) = linspace(dv*sensor.i1,dv*sensor.i2,sensor.N)';

end





% misc parameters/syntax from TVAC analysis code:
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



