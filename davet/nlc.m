%
% function nlc_cxs = nlc(inst, iFov, scene_cxs, space_cxs, eng)
%
% University of Wisconsin Nonlinearity Correction for CrIS FM1
%
% Inputs:
%   inst            sensor params from inst_params, with numeric filter
%   iFov            FOV index, 1 to 9
%   scene_cxs       Uncorrected scene complex spectrum (Nchan x 1)
%   space_cxs       Uncorrected space view complex spectrum (Nchan x 1) (Must be same IFG sweep 
%                     direction as scene_cxs, and better to have this be an average of many view)
%   eng             current eng (4 min) packet struct, from the MIT RDR reader
%
% Outputs:
%   nlc_cxs      Nonlinearity corrected scene spectrum (Nchan x 1)
%   extra           (Optional) A structure of various parameters used in the NLC
%
% Sample usage:
%   [nlc_cxs, extra] = nlc(inst, 1, wn, scene_cxs, space_cxs, d1.packet);
%
% University of Wisconsin DC Level Model for CrIS FM1
%
% This version implements the integral of the magnitude spectrum between band limits
% using the following formula:
%   Vdc = F(target - space)/modeff + Vinst
%   where
%   F(x) = twice the integral between [v1,v2] of magnitude of complex spectrum x 
%          (factor of 2 accounts for integration over plus and minus frequencies)
% Notes:
%   (1) This equation assumes that the space view is colder than any potential scene views.
%   (2) F(x) must be normalized to be consistent with a2 parameter!
%   (3) The spectral integral should avoid band guard regions.
%   (4) It is recommended that an average spectrum be used for the space_cxs
%
% History:
%   Copyright 2008 University of Wisconsin-Madison Space Science and Engineering Center
%   Revision: 18 June 2008  ROK, UW-SSEC
%   Revision: 24 June 2008  JKT, UW-SSEC, converted to work within quickCAL framework
%   Revision: 25 June 2008  ROK, UW-SSEC Added defiltering
%   Revision: 07 July 2008  ROK, UW-SSEC Normalize integral to unfiltered ZPD
%   Revision: 08 July 2008  JKT, UW-SSEC, converted to work within quickCAL framework
%   Revision: 24 Nov 2008   JKT, UW-SSEC
%   11 Nov 2011, DCT, renamed nlc.m and mods to work with the MIT LL format input and other mods
%   regarding form of input variables and passing of variables to DC level function.
%   09 Feb 2012, DCT, fixed bug in extracting PGA gain values from 4-min-eng packet (!!!)
%   28 Feb 2012, DCT, preliminary a2 scale factors based on DM and Fov-2-Fov analysis
%   19 Nov 2012, DCT, a2 scale factors based on Fov-2-Fov analysis of IDPS/ADL processing
%
%   18 Aug 2013, DCT, re-written to:
%     a) use a2 values in units of inverse volts, 
%     b) a2, mod-eff, and Vinst values are 07 Aug 2013 UW values.
%     c) work with new DC level model function which uses Vinst as 
%        background contribution and V in units of volts.
%
%   8 Dec 2013, HM 
%   - replaced v and control with sensor-grid struct "inst"
%   - modifed to work with numeric filter from the time domain
%     representation.  This leaves the frequency domain filter on
%     the current sensor grid, so the old frequency matching code 
%     was not needed.  But this does required normalizing the new
%     filter to match the old.
%
%   24 Nov 2014, HM
%   - dropped the separate "band" param, this is in the inst struct
%   - added the full eng packet as a param, with PGAgain, modEff,
%     and Vinst read from that.  Matlab is call-by-reference for
%     compound objects unless the passed in parameter is modified,
%     so there is no overhead for this.
%   - simplified setting up parameterss for the nonlinearity calc 
%   - folded DClevel_model into nlc because it was only two lines 
%     of code after mods as noted above

function nlc_cxs = nlc(inst, iFov, scene_cxs, space_cxs, eng)

% band index
switch upper(inst.band)
  case 'LW', bi = 1;
  case 'MW', bi = 2;  
  case 'SW', bi = 3;
  otherwise, error('bad band spec');
end

% get a2 from inst or eng
if isfield(inst, 'a2') && ~isempty(inst.a2)
  a2 = inst.a2;
else
  a2 = eng.Linearity_Param.Band(bi).a2;
end

% nonlinearity params from eng
PGAgain = eng.PGA_Gain.Band(bi).map(eng.PGA_Gain.Band(bi).Setting+1);
modEff  = eng.Modulation_eff.Band(bi).Eff;
Vinst   = eng.Linearity_Param.Band(bi).Vinst;

% modEff test hack
% switch upper(inst.band)
%   case 'LW', modEff = [0.7560  0.7640  0.7590  0.7680  0.7950  0.7700  0.7720  0.7820  0.7710];
%   case 'MW', modEff = [0.7890  0.7840  0.7780  0.7890  0.8000  0.7910  0.7780  0.8040  0.7930];
%   case 'SW', modEff = [0.6540  0.6620  0.6430  0.6640  0.6860  0.6600  0.6670  0.6830  0.6570];
% end

% choose a single FOV (for now...)
a2 = a2(iFov);
PGAgain = PGAgain(iFov); 
modEff = modEff(iFov); 
Vinst = Vinst(iFov); 

% normalize NF to match Dave's 2008 filter
switch upper(inst.band)
  case 'LW',  inst.sNF = 1.6047 * inst.sNF ./ max(inst.sNF);
  case 'MW',  inst.sNF = 0.9826 * inst.sNF ./ max(inst.sNF);
  case 'SW',  inst.sNF = 0.2046 * inst.sNF ./ max(inst.sNF);
end

% divide the complex spectra by the numerical filter
scene_cxs = scene_cxs ./ inst.sNF;
space_cxs = space_cxs ./ inst.sNF;

% Compute the DC level "normalization factor".  This is required to make 
% the sum of the magnitude integral match the unfiltered ZPD count value.
norm_factor = 1/(inst.df*inst.npts);

% Analog to Digital gain
gain_AD = 8192/2.5;

% integrate magnitude of scene minus space
F_scene_minus_space = norm_factor*(2*sum(abs(scene_cxs - space_cxs)));

% get the DC level
Vdc = (F_scene_minus_space./modEff) ./ (gain_AD .* PGAgain) + Vinst;

% Compute 2*a2*Vdc*CXS as the "linear" cross-term of the quadratic nonlinearity correction
lincorr_cxs = 2.*a2.*Vdc.*scene_cxs;

% The a2*I^2 "squared" contribution of the quadratic nonlinearity correction is identically zero
sqcorr_cxs = 0;

% Add computed nonlinearity correction to original complex spectrum 
nlc_cxs = scene_cxs + lincorr_cxs + sqcorr_cxs;

% ITT equation
% nlc_cxs = scene_cxs ./ (1 - 2.*a2.*Vdc);

