

function [spec_out] = cris_spectral_resample_CCAST(spec_in,user,sensor,os_factor);

%
% function [spec_out] = cris_spectral_resample_CCAST(spec_in,user,sensor,os_factor);
%
% Spectrally resample a CrIS spectrum from the sensor grid to the user grid 
% via double FFTs and interpolation in the oversampled IFG domain.
%
% Inputs:
%    spec_in       input radiance spectrum [Nchan x 1], on the sensor wavenumber grid
%    user          structure of user grid parameters, from cris_spectral_params_CCAST.m
%    sensor        structure of sensor grid parameters, from cris_spectral_params_CCAST.m
%    os_factor     (Optional) oversampling factor (Default is 4).  Should be 2^n.
%
% Outputs:
%    spec_out      output radiance spectrum [Nchan x 1], on the user wavenumber grid and
%                  with the user Max OPD.
%
% DCT, 14-Nov-2011
%


%%%%%%%%% Produce an oversampled interferogram corresponding to spec_in

% the oversample factor and the type of IFG interpolation (below, cubic spline)
% can be traded vs. one another to optimize accuracy and speed.
if nargin <= 3
  os_factor = 2^2;
end

% Create a wavenumber scale and spectrum of zeros going from 0 to 
% sensor.vlaser 1/cm with vlaser/dv+1 points and dv.
wn_jnk = linspace(0,sensor.vlaser*os_factor,sensor.vlaser*os_factor/sensor.dv+1)';
r = wn_jnk*0;

% And insert the in-band sepctrum into the array
ind1 = sensor.i1+1;
ind2 = sensor.i2+1;
r(ind1:ind2) = spec_in;

% "Butterfly" the spectrum 
r2 = [r(1:end-1) ; flipud(r(2:end))];
wn_jnk2 = [wn_jnk(1:end-1) ; -flipud(wn_jnk(2:end))];

% And FFT the spectrum to get the oversampled interferogram
ifg_os = fftshift(real(fft(r2)));

% And compute the corresponding OPD scale
jnk = linspace(0,sensor.MOPD,length(r2)/2+1)';
opd_os = [-flipud(jnk(2:end));jnk(1:end-1)];

% (A Check: IFFT back to get spectrum: jnk should be same as r2)
% jnk = ifft(fftshift(ifg_os));


%%%%%%%% Interpolate the oversampled interferogram to the user grid sample points

% Define user grid in opd space
jnk = linspace(0,user.MOPD,length(r2)/2+1)';
user.opd_os = [-flipud(jnk(2:end));jnk(1:end-1)];  % OPDs (cm)

% Interpolate the oversampled interferogram to the user opd grid 
ifg2_os = interp1(opd_os,ifg_os,user.opd_os,'spline');


%%%%%%%% Compute the corresponding spectrum and pull out the in-band region

spec_out = ifft(fftshift(ifg2_os))*sensor.dv/user.dv;
index = (user.i1+1:user.i2+1)';
spec_out = spec_out(index);

% imaginary part should be zero to within machine precision
spec_out = real(spec_out);
