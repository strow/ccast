
function [Vdc,F_target_minus_space]  = DClevel_model(v,scene_cxs,space_cxs,norm_factor,modeff,Vinst,PGAgain);

%
% function [Vdc,F_target_minus_space]  = DClevel_model(v,scene_cxs,space_cxs,norm_factor,modeff,Vinst,PGAgain);
%
% University of Wisconsin DC Level Model for CrIS FM1
%
% This version implements the integral of the magnitude spectrum between band limits
% using the following formula:
%   Vdc = F(target - space)/modeff + Vinst
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
%   scene_cxs       = current scene complex spectrum
%   space_cxs       = space view complex spectrum
%   norm_factor     = scalar value used for normalization (tbd)
%   modeff          = modulation efficiency
%   Vinst           = instrument contribution to DC level
%   PGAgain         = current PGA gain value
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
%       integration function removed; done inline here
%   18 Aug 2013, DCT, edited to a) produce DC levels in units of volts, and b) instrument
%       contribution is Vinst versus kfac*F_space/modeff
%   6 Dec 2013, HM, dropped frequency subsetting since the NF is now calculated from the
%       time domain representation at the current sensor grid
%

% Difference between scene and space views
scene_minus_space_cxs = scene_cxs - space_cxs;

% Integrals ...  (This was previously in its own function "Integrate_Magnitude_Spectrum.m")
%   F(x) = Normization*(twice the sum of the magnitude of complex spectrum x between [v1,v2]).  Notes:
%   (1) Factor of 2 accounts for integration over plus and minus frequencies.
%   (2) Normalized to match the unfiltered ZPD value used to define a2.

% Analog to Digital gain
gain_AD = 8192/2.5;

F_target_minus_space = norm_factor*(2*sum(abs(scene_minus_space_cxs)));

Vdc = (F_target_minus_space./modeff) ./ (gain_AD .* PGAgain) + Vinst;

