
function radout = applyITTbandguards(radin,sensor);

%
% function radout = cris_applyITTbandgurads_CCAST(radin,sensor);
%
% Apply ITT band guards to a matrix of CrIS spectra
%
% Inputs:
%  radin       A matrix of radiance spectra on the sensor wavenumber grid, 
%              as output of calmain2.m with dimensions nChan x 9 x 30 x nScans.
%  sensor      structure of sensor parameters
%
% Outputs:
%  radout     Matrix of spectra with band guard rolloffs applied
%
%
% DCT 22-Nov-2011
% DCT 09 Dec 2011 - removed "vin", wavenumbers as input ... not used.
% DCT 12 Dec 2011 - setting band guard function to zero at band edges

[nChan,nFov,nFORs,nScans] = size(radin); 

radout = radin*0;

fb = ITTbandguards(sensor.band);
% Force band guard to zero at band edges
ind = find(sensor.v_onaxis <= sensor.vb(1) | sensor.v_onaxis >= sensor.vb(4));
fb(ind) = 0;

for iFov = 1:nFov
  for iFOR = 1:nFORs
    for iScan = 1:nScans
      radout(:,iFov,iFOR,iScan) = radin(:,iFov,iFOR,iScan) .* fb;
    end
  end
end
