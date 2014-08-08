
function [nu_over_nu0,weight] = offAxisWeights(FOVangle,FOVradius);

%
% function [nu_over_nu0,weight] = offAxisWeights(FOVangle,FOVradius);
%
% Sinc function weights for an off-axis circular FOV, from Genest
% and Tremblay, Applied Optics, Vol 38 No 25, 1999, and derived by
% Hank using the notation below:
%
% Inputs:
%   FOVangle:     Angle in radians from FTS axis to center of FOV (scalar)
%   FOVradius:    Angle in radians of FOV radius (scalar)
%
% Outout:
%   nu_over_nu0:  x-scale for weights; ratio of wavenumber to
%                 channel center wavenumber.
%   weight:       weights
%
% DCT, 11-Dec-2011
%

% This is the scale for computing the weights.  
% This could be written more robustly for general input but for now
% the user should ensure that the lower limit is low enough to
% handle the off-axis parameter inputs.  E.g.  Look to see that
% weight has gone to zero at the lower limit.
nu_over_nu0 = (0.996:1E-6:1.001)';

rho = sqrt(2*(1-nu_over_nu0));
weight = rho*0;
if FOVangle <= FOVradius
  ind = find(rho <= FOVradius-FOVangle & imag(rho)==0);
  weight(ind) = 1;
end
ind = find(rho >= abs(FOVradius-FOVangle) & rho <= FOVradius+FOVangle);
jnk = acos((rho(ind).^2 + FOVangle^2 - FOVradius^2)./(2*FOVangle*rho(ind)));
weight(ind) = jnk/max(jnk);

% normalize the weights so they sum to 1
weight = weight/sum(weight);

