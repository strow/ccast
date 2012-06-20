
function radout = selfApodCorr(radin,isa);

%
% function radout = selfApodCorr(radin,isa);
%
% Apply self-apodization correction to CrIS spectra with
% matrix multiply.
%
% Inputs:
%  radin       A matrix of radiance spectra on the sensor wavenumber grid, 
%              as output of calmain2.m with dimensions nChan x 9 x 30 x nScans.
%  isa         A structure of correction matrices, as produced within ccast.m using
%              computeISA.m.  E.g. if radin are LW radiances then isa is isa.lw.
%
% Outputs:
%  radout     Matrix of spectra with self-apodization correction applied.
%
%
% DCT 22-Nov-2011
%

[nChan,nFov,nFORs,nScans] = size(radin); 

radout = radin*0;

for iFov = 1:nFov
  for iFOR = 1:nFORs
    for iScan = 1:nScans
      radout(:,iFov,iFOR,iScan) = isa(iFov).isa * radin(:,iFov,iFOR,iScan);
    end
  end
end
