
function radout = applyResampling(radin,user,sensor,mode);

%
% function radout = applyResampling(radin,user,sensor,mode);
%
% Spectral resample from on-axis sensor grid to user grid.
%
% Inputs:
%  radin       A matrix of radiance spectra on the sensor wavenumber grid, 
%              as output of calmain2.m with dimensions nChan x 9 x 30 x nScans.
%  user        User grid structure, from spectral_params.m
%  sensor      Sensor grid structure, from spectral_params.m
%  mode        Which approach to use: 1=Matrix, 2=DoubleFFT
%
% Outputs:
%  radout      Spectra resampled to user grid and user resolution.
%
% DCT 22-Nov-2011
% DCT 12-Dec-2011
%

[nChan,nFov,nFORs,nScans] = size(radin);

radout = radin*NaN;

% Compute resampling matrix
arg1 = repmat(sensor.v_onaxis,1,user.N);
arg2 = repmat(user.v,1,user.N);
arg3 = (arg1'-arg2)/user.dv;
F1 = (sensor.dv_onaxis/user.dv)*sinc(arg3)./sinc(arg3/user.N);

if mode == 1

  %% Resampling matrix approach ala Bomem:
  for iFov = 1:nFov;  for iFOR = 1:nFORs;  for iScan = 1:nScans
    radout(:,iFov,iFOR,iScan) = F1 * radin(:,iFov,iFOR,iScan);
  end; end; end

elseif mode == 2

  %% Double FFT approach
  for iFov = 1:nFov;  for iFOR = 1:nFORs;  for iScan = 1:nScans
    try  % this is a catch-all for bad input, primarily NaNs in radin
      radout(:,iFov,iFOR,iScan) = ...
         spectral_resample(radin(:,iFov,iFOR,iScan),user,sensor);
    end
  end; end; end

end
