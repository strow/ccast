
function rad = radcal(ratio,ictrad);

%
% function rad = cris_radcal(ratio,ictrad);
%
% Do radiometric calibraiton given real part of complex ratio, rLW,
% and ICT predicted radiances.  Inputs are obtained with ccast
% calmode=2 using calmain2.m.
%
% Inputs:
%   ratio    [nChan x 9 x 30 x nScans] array of real part of complex
%            count ratio (Ces-Csp)/(Cit-Csp)
%
%  ictrad    [nChan x 9 x nScans] array of ICT predicted radiances
%
%

[nChans,nFovs,nFOR,nScans] = size(ratio);

rad = ratio*0;

for iFov = 1:nFovs
  for iFOR = 1:nFOR
    for iScan = 1:nScans
      rad(:,iFov,iFOR,iScan) = ratio(:,iFov,iFOR,iScan).*ictrad(:,iFov,iScan);
    end
  end
end
