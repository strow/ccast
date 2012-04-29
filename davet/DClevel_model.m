
function [Vdc]  = DClevel_model(v,vlo,vhi,scene_cxs,space_cxs,norm_factor,modeff,kfac);

%
% function [Vdc]  = DClevel_model(v,vlo,vhi,scene_cxs,space_cxs,norm_factor,modeff,kfac);
%
% University of Wisconsin DC Level Model for CrIS FM1
%
% This version implements the integral of the magnitude spectrum between band limits
% using the following formula:
%   Vdc = F(target - space)/modeff + kfac*F(space)/modeff
%   where
%   F(x) = twice the integral between [v1,v2] of magnitude of complex spectrum x 
%          (factor of 2 accounts for integration over plus and minus frequencies)
%
% Notes:
%   (1) This equation assumes that the space view is colder than any potential scene views.
%   (2) F(x) must be normalized to be consistent with a2 parameter!
%   (3) The spectral integral should avoid band guard regions.
%   (4) It is recommended that an average spectrum be used for the space_cxs
%
% Inputs: 
%   v               = wavenumber scale
%   vlo             = lower wavenumber limit to use in spectral integral
%   vhi             = upper wavenumber limit to use in spectral integral
%   scene_cxs       = current scene complex spectrum
%   space_cxs       = space view complex spectrum
%   norm_factor     = scalar value used for normalization (tbd)
%   kfac            = background factor
%   modeff          = modulation efficiency
%
% Output:
%   Vdc             = Estimated DC level
%
%
% History:
%   Copyright 2008 University of Wisconsin-Madison Space Science and Engineering Center
%   Revision: 29 May  2008  ROK, UW-SSEC
%   Revision: 18 June 2008  ROK, UW-SSEC
%   Revision: 24 June 2008  JKT, UW-SSEC, converted to work within quickCAL framework
%   Revision: 25 June 2008  ROK, UW-SSEC Added defiltering. Included "dv" in integral.
%   Revision: 07 July 2008  ROK, UW-SSEC Using function to compute normalized integral
%   Revision: 08 July 2008  JKT, UW-SSEC, converted to work within quickCAL framework
%   11 Nov 2011   DCT, renamed DClevel_model.m, format of inputs modified and call to 
%           integration function removed; done inline here
%

% Difference between scene and space views
scene_minus_space_cxs = scene_cxs - space_cxs;

% Integrals ...  (This was previously in its own function "Integrate_Magnitude_Spectrum.m")
%   F(x) = Normization*(twice the sum of the magnitude of complex spectrum x between [v1,v2]).  Notes:
%   (1) Factor of 2 accounts for integration over plus and minus frequencies.
%   (2) Normalized to match the unfiltered ZPD value used to define a2.

v_indices = find(v >= vlo & v <= vhi);

F_target_minus_space = norm_factor*(2*sum(abs(scene_minus_space_cxs(v_indices))));

F_space = norm_factor*(2*sum(abs(space_cxs(v_indices))));

Vdc = F_target_minus_space./modeff + kfac.*F_space./modeff;

