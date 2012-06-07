
function [isa,extra] = cris_computeISA_CCAST(v,MOPD,FOVangle,FOVradius);

%
% function [isa,extra] = cris_computeISA_CCAST(v,MOPD,FOVangle,FOVradius);
%
% Compute a self-apodization correction matrix (SA^-1) for CrIS FM1.  This function 
% can be used otherwise, but it is intended to be used with "sensor" input parameters 
% (e.g. sensor wavenumbers and sensor Max OPD) and applied to measured spectra on 
% the corresponding sensor grid, resulting in output/corrected radiance spectrum is 
% reported on the same sensor wavenumber grid.  That is, it does not do any 
% resampling.  Some comments are specific to CrIS FM1, although the function 
% can be used for other sensors.
%
% Inputs:
%
%   v          Sensor (aka measured) grid wavenumber vector (1/cm) [Nchan x 1], with 
%                 Nchan = 864 (lw), 528 (mw), 200 (sw)
%   MOPD       Sensor Maximum Optical Path Difference (cm) [scalar].  For an assumed 
%                 metrology wavelength of lambda (nm), this is Nchan*Rf*lambda/2/1E7 
%                 where Rf =24 (lw), 20 (mw), 26 (sw)
%   FOVangle   Off-axis angle to center of FOV, (radians) [1x1]
%                    [CrIS: 0 center (5), 0.0192 edge (2,4,6,8), 0.0272 corner (1,3,7,9)]
%   FOVradius  Radius of circular FOV, (radians) [1x1]
%                    [CrIS: 7/833~=0.0084]
%
% Outputs:
%   isa        Inverse of the Self-Apodization matrix, such that corrected spectra = isa * rad;
%
% History:
%   DCT, 14 Nov 2011,  guts pulled from computeIls.m
%


% Sinc function weights for an off-axis circular FOV, from Genest and Tremblay, Applied 
% Optics, Vol 38 No 25, 1999, and independently derived by Hank using the notation below:
nu_over_nu0 = (0.996:1E-6:1.001)';
rho = sqrt(2*(1-nu_over_nu0));
dg.s = FOVangle;
dg.Rtheta = FOVradius;
weight = rho*0;
if dg.s <= dg.Rtheta
  ind = find(rho <= dg.Rtheta-dg.s & imag(rho)==0);
  weight(ind) = 1;
end
ind = find(rho >= abs(dg.Rtheta -dg.s) & rho <= dg.Rtheta+dg.s);
jnk = acos((rho(ind).^2 + dg.s^2 - dg.Rtheta^2)./(2*dg.s*rho(ind)));
weight(ind) = jnk/max(jnk);
% normalize the weights so they sum to 1
weight = weight/sum(weight);

% Compute the SA matrix
sa = zeros(length(v));

for iChan = 1:length(v)
  v0 = v(iChan);
  % Sum the (shifted) pure sincs with the weights to get the expected ILS
  v_weight = nu_over_nu0 * v0;
  ils = zeros(length(v),1);
  for i = 1:length(weight)
    if weight(i) ~= 0
      ils = ils + weight(i)*nu_over_nu0(i)^2*sinc((v-v_weight(i))*2*MOPD*nu_over_nu0(i));
    end
  end
  sa(:,iChan) = ils;
end

% And the inverse
isa = inv(sa);

% Perform the correction:
% spec1 = isa*sensor.rad;




