
function [ils,pure_sinc,extra] = computeIls(v,v0,MOPD,FOVangle,FOVradius);

%
% function [ils,pure_sinc,extra] = computeIls(v,v0,MOPD,FOVangle,FOVradius);
%
% Compute ILSs for an FTS with circular FOV
%
% Inputs:
%     v          wavenumber grid, 1/cm (Nx1)
%     v0         channel center, 1/cm
%     MOPD       Max Optical Path Difference, cm (1x1)
%                    [CrIS: =0.8037 LW, 0.4093 MW, 0.2015 (SW)]
%     FOVangle   Full off-axis angle to center of FOV, rad (1x1)
%                    [CrIS: 0 center (5), 0.0192 edge (2,4,6,8), 0.0272 corner (1,3,7,9)]
%     FOVradius  radius of circular FOV, rad (1x1)
%                    [CrIS: 7/833~=0.0084]
% Output:
%     ils        ILS computed at wavenumbers v
%     pure_sinc  pure sinc ILS computed at v0
%     extra      FWHM, centroid, and foot amplitudes of ils and pure_sinc
%
% DCT, 12/09/2005
% DCT, 05/02/2011 Normalization corrected, ala Strow and Hannon.
% DCT, 05/18/2011 more normalization corrections
%

dg.s = FOVangle;
dg.Rtheta = FOVradius;

% Sinc function weights for an off-axis circular FOV, from Genest and Tremblay, Applied Optics, Vol 38 No 25, 1999, 
% and independently derived by Hank using the notation below:
nu_over_nu0 = (0.996:1E-6:1.001)';
rho = sqrt(2*(1-nu_over_nu0));
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

% Sum the (shifted) pure sincs with the weights to get the expected ILS
v_weight = nu_over_nu0 * v0;
ils = zeros(length(v),1);
for i = 1:length(weight)
  if weight(i) ~= 0
%    ils = ils + weight(i)*sinc((v-v_weight(i))*2*MOPD);
%    ils = ils + weight(i)*nu_over_nu0(i)*sinc((v-v_weight(i))*2*MOPD);
    ils = ils + weight(i)*nu_over_nu0(i)^2*sinc((v-v_weight(i))*2*MOPD*nu_over_nu0(i));
  end
end

% Normalize
%ils = ils/max(ils);   % WRONG normalization!
%ils = ils/sum(ils);    % correct normalization for matrix application - also wrong.



% Also compute pure since function at v0
pure_sinc = sinc((v-v0)*2*MOPD);

% fill output structure w/ input parameters
extra.v0 = v0;
extra.MOPD = MOPD;
extra.FOVangle = FOVangle;
extra.FOVradius = FOVradius;
extra.nu_over_nu0 = nu_over_nu0;
extra.weight = weight;

% Compute FWHM, centroid, and first foot amplitudes
%[extra.fwhm,extra.pos,extra.lfoot,extra.rfoot] = fwhm(v,ils,[v0-5 v0+5]);
%[extra.fwhm0,extra.pos0,extra.lfoot0,extra.rfoot0] = fwhm(v,pure_sinc,[v0-5 v0+5]);

