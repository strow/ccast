%
% create focal plane files from ccast spectral_params.m
%

band = 'lw';
wl_laser = 775; % nominal value, not used here
[user,sensor] = spectral_params(band,wl_laser);

foax = sensor.FOVangle(:);
frad = sensor.FOVradius(:);
save fp_ccastLW foax frad

band = 'mw';
wl_laser = 775; % nominal value, not used here
[user,sensor] = spectral_params(band,wl_laser);

foax = sensor.FOVangle(:);
frad = sensor.FOVradius(:);
save fp_ccastMW foax frad

band = 'sw';
wl_laser = 775; % nominal value, not used here
[user,sensor] = spectral_params(band,wl_laser);

foax = sensor.FOVangle(:);
frad = sensor.FOVradius(:);
save fp_ccastSW foax frad

