
function [nlcorr_cxs,extra] = nlc(band,iFov,v,scene_cxs,space_cxs,PGA_Gain,control)

%
% function [nlcorr_cxs,extra] = nlc(band,iFov,v,scene_cxs,space_cxs,PGA_Gain,control)
%
% University of Wisconsin Nonlinearity Correction for CrIS FM1
%
% Inputs:
%   band            Spectral band: "lw", "mw" or "sw"
%   iFov            FOV index, 1 to 9
%   v               Wavenumber scale (Nchan x 1) with Nchan = 864 (lw), 528 (mw), 200 (sw)
%   scene_cxs       Uncorrected scene complex spectrum (Nchan x 1)
%   space_cxs       Uncorrected space view complex spectrum (Nchan x 1) (Must be same IFG sweep 
%                     direction as scene_cxs, and better to have this be an average of many view)
%   PGA_Gain        Structure of RDR file PGA Gain values, as read from MIT RDR reader in d1.packet.PGA_Gain
%   control         (Optional) Structure of DC level parameters and Numerical Filter.  If not input, this structure is
%                     constructed from DClevel_parameters_22July2008.mat and NF_dct_20080617modified.mat
%                     which must be in the user path.
%
% Outputs:
%   nlcorr_cxs      Nonlinearity corrected scene spectrum (Nchan x 1)
%   extra           (Optional) A structure of various parameters used in the NLC
%
% Sample usage:
%   [nlcorr_cxs,extra] = nlc('lw',1,wn,scene_cxs,space_cxs,d1.packet.PGA_Gain);
%
% Required Functions:
%       DClevel_model.m
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
%      a) use a2 values in units of inverse volts, 
%      b) a2, mod-eff, and Vinst values are 07 Aug 2013 UW values.
%      c) work with new DC level model function which uses Vinst as background contribution and V in units of volts.
%

% Extract numerical filter info/data
NF = control.NF;

% Insert hard-coded Vinst values into control structure.  These are v34 EP values.
control.DClevel_parameters.Vinst.lw = [1.36500   1.42370   1.42830   1.41930   1.32880   1.46600   1.47150   1.40460   1.37920];
control.DClevel_parameters.Vinst.mw = [0.63620   0.60160   0.63600   0.61420   0.56100   0.65130   0.58310   0.61160   0.67520];
control.DClevel_parameters.Vinst.sw = [0.00000   0.00000   0.00000   0.00000   0.00000   0.00000   0.00000   0.00000   0.00000];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Define a2 values
%
% These are 07-Aug-2013 UW a2 values in units of inverse volts.  Ref: uw_recommended_nlc_coefficients_07Aug2013.ppt

a2_now.lw = [0.01936   0.01433   0.01609   0.02192   0.01341   0.01637   0.01464   0.01732   0.03045];
a2_now.mw = [0.00529   0.02156   0.02924   0.01215   0.01435   0.00372   0.10702   0.04564   0.00256];
a2_now.sw = [0.00000   0.00000   0.00000   0.00000   0.00000   0.00000   0.00000   0.00000   0.00000];

% Apply additional overall (FOV independent) emperical scale factors
global A2_SCALE_FACTOR
A2_SCALE_FACTOR = 1;
a2_now.lw = a2_now.lw * A2_SCALE_FACTOR;
a2_now.mw = a2_now.mw * A2_SCALE_FACTOR;
a2_now.sw = a2_now.sw * A2_SCALE_FACTOR;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Define PGA gains
pgaGain_now.lw = PGA_Gain.Band(1).map(PGA_Gain.Band(1).Setting+1);
pgaGain_now.mw = PGA_Gain.Band(2).map(PGA_Gain.Band(2).Setting+1);
pgaGain_now.sw = PGA_Gain.Band(3).map(PGA_Gain.Band(3).Setting+1);


%
% Define limits for spectral integrals, reduction factors, and # normal mode spectral points.  
% Divide the complex spectra by the numerical filter.  Also pull out values of a2, Vinst, modulation 
  % efficiency, and PGA-gain for this FOV, this band.
%
switch upper(band)

  case 'LW'
    reduction_factor = 24;
    npoints_nm = NF.lw_npoints_nm;
    v_lo = min(NF.vlw); v_hi = max(NF.vlw); 
    scene_cxs = scene_cxs./NF.lw;
    space_cxs = space_cxs./NF.lw;
    a2 = a2_now.lw(iFov);
    modEff = control.DClevel_parameters.ModEff.lw(iFov);
    vinst = control.DClevel_parameters.Vinst.lw(iFov);
    PGAgain = pgaGain_now.lw(iFov);

  case 'MW'
    reduction_factor = 20;
    npoints_nm = NF.mw_npoints_nm;
    v_lo = min(NF.vmw); v_hi = max(NF.vmw); 
    scene_cxs = scene_cxs./NF.mw;
    space_cxs = space_cxs./NF.mw;
    a2 = a2_now.mw(iFov);
    modEff = control.DClevel_parameters.ModEff.mw(iFov);
    vinst = control.DClevel_parameters.Vinst.mw(iFov);
    PGAgain = pgaGain_now.mw(iFov);

  case 'SW'
    reduction_factor = 26;
    npoints_nm = NF.sw_npoints_nm;
    v_lo = min(NF.vsw); v_hi = max(NF.vsw);
    scene_cxs = scene_cxs./NF.sw;
    space_cxs = space_cxs./NF.sw;
    a2 = a2_now.sw(iFov);
    modEff = control.DClevel_parameters.ModEff.sw(iFov);
    vinst = control.DClevel_parameters.Vinst.sw(iFov);
    PGAgain = pgaGain_now.sw(iFov);

end

%
% Compute the DC level "normalization factor".  This is required to make the
% sum of the magnitude integral match the unfiltered ZPD count value.
%
norm_factor = 1/(reduction_factor*npoints_nm);


% Compute the DC level
%
[Vdc,F_target_minus_space] = DClevel_model(v,v_lo,v_hi,scene_cxs,space_cxs,norm_factor,modEff,vinst,PGAgain);

%
% Compute 2*a2*Vdc*CXS as the "linear" cross-term of the quadratic nonlinearity correction
%
lincorr_cxs = 2.*a2.*Vdc.*scene_cxs;

%
% The a2*I^2 "squared" contribution of the quadratic nonlinearity correction is identically zero
%
sqcorr_cxs = 0;

%
% Add computed nonlinearity correction to original complex spectrum 
%
nlcorr_cxs = scene_cxs + lincorr_cxs + sqcorr_cxs;

%% ITT equation
%nlcorr_cxs = scene_cxs ./ (1 - 2.*a2.*Vdc);


if nargout == 2
  extra.band = band;
  extra.iFov = iFov;
  extra.a2 = a2;
  extra.norm_factor = norm_factor;
%  extra.kfac = kfac;
  extra.modEff = modEff;
  extra.vinst = vinst;
%  extra.control = control;
%  extra.a2_now = a2_now;
%  extra.pgaGain_now = pgaGain_now;
%  extra.a2_tvac3_mn1_ext = a2_tvac3_mn1_ect;
%  extra.pgaGain_tvac3_mn1 = pgaGain_tvac3_mn1;
  extra.Vdc = Vdc;
  extra.F_target_minus_space = F_target_minus_space;
%  extra.F_space = F_space;
end
