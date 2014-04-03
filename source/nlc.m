%
% function [nlcorr_cxs,extra] = nlc(band,iFov,v,scene_cxs,space_cxs,PGA_Gain,inst)
%
% University of Wisconsin Nonlinearity Correction for CrIS FM1
%
% Inputs:
%   band            Spectral band: "lw", "mw" or "sw"
%   iFov            FOV index, 1 to 9
%   scene_cxs       Uncorrected scene complex spectrum (Nchan x 1)
%   space_cxs       Uncorrected space view complex spectrum (Nchan x 1) (Must be same IFG sweep 
%                     direction as scene_cxs, and better to have this be an average of many view)
%   PGA_Gain        Structure of RDR file PGA Gain values, as read from MIT RDR reader in d1.packet.PGA_Gain
%   inst            sensor parameters from inst_params, including numeric filter added
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
%   8 Dec 2013, HM, 
%      - added hard coded ModEff values for now, below
%      - replaced v and control with sensor-grid struct "inst"
%      - added numeric filter as a field sNF of the inst struct
%

function [nlcorr_cxs,extra] = nlc(band,iFov,v,scene_cxs,space_cxs,PGA_Gain,inst)

% Insert hard-coded Vinst values into control structure.  These are v34 EP values.
DClevel_parameters.Vinst.lw = [1.36500  1.42370  1.42830  1.41930  1.32880  1.46600  1.47150  1.40460  1.37920];
DClevel_parameters.Vinst.mw = [0.63620  0.60160  0.63600  0.61420  0.56100  0.65130  0.58310  0.61160  0.67520];
DClevel_parameters.Vinst.sw = [0.00000  0.00000  0.00000  0.00000  0.00000  0.00000  0.00000  0.00000  0.00000];

% hard-coded ModEff values from 'UW Parameters for DC-Level-22July08.xls'
DClevel_parameters.ModEff.lw = [0.7560  0.7640  0.7590  0.7680  0.7950  0.7700  0.7720  0.7820  0.7710];
DClevel_parameters.ModEff.mw = [0.7890  0.7840  0.7780  0.7890  0.8000  0.7910  0.7780  0.8040  0.7930];
DClevel_parameters.ModEff.sw = [0.6540  0.6620  0.6430  0.6640  0.6860  0.6600  0.6670  0.6830  0.6570];

% Define a2 values.  
% These are 07-Aug-2013 UW a2 values in units of inverse volts.  
% Ref: uw_recommended_nlc_coefficients_07Aug2013.ppt
a2_now.lw = [0.01936  0.01433  0.01609  0.02192  0.01341  0.01637  0.01464  0.01732  0.03045];
a2_now.mw = [0.00529  0.02156  0.02924  0.01215  0.01435  0.00372  0.10702  0.04564  0.00256];
a2_now.sw = [0.00000  0.00000  0.00000  0.00000  0.00000  0.00000  0.00000  0.00000  0.00000];

% Apply additional overall (FOV independent) emperical scale factors
% global A2_SCALE_FACTOR
A2_SCALE_FACTOR = 1;
a2_now.lw = a2_now.lw * A2_SCALE_FACTOR;
a2_now.mw = a2_now.mw * A2_SCALE_FACTOR;
a2_now.sw = a2_now.sw * A2_SCALE_FACTOR;

% Define PGA gains
pgaGain_now.lw = PGA_Gain.Band(1).map(PGA_Gain.Band(1).Setting+1);
pgaGain_now.mw = PGA_Gain.Band(2).map(PGA_Gain.Band(2).Setting+1);
pgaGain_now.sw = PGA_Gain.Band(3).map(PGA_Gain.Band(3).Setting+1);

% select a2, Vinst, modulation efficiency, and PGA-gain for this FOV and band
switch upper(band)

 case 'LW'
    a2 = a2_now.lw(iFov);
    modEff = DClevel_parameters.ModEff.lw(iFov);
    vinst = DClevel_parameters.Vinst.lw(iFov);
    PGAgain = pgaGain_now.lw(iFov);

 case 'MW'
    a2 = a2_now.mw(iFov);
    modEff = DClevel_parameters.ModEff.mw(iFov);
    vinst = DClevel_parameters.Vinst.mw(iFov);
    PGAgain = pgaGain_now.mw(iFov);

  case 'SW'
    a2 = a2_now.sw(iFov);
    modEff = DClevel_parameters.ModEff.sw(iFov);
    vinst = DClevel_parameters.Vinst.sw(iFov);
    PGAgain = pgaGain_now.sw(iFov);
end

%%%%%% begin hack block
% [nlcorr_cxs2,extra2] = nlc_dt(band,iFov,v,scene_cxs,space_cxs,PGA_Gain,inst);

% normalize NF to match Dave's 2008 filter
switch upper(band)
  case 'LW',  inst.sNF = 1.6047 * inst.sNF ./ max(inst.sNF);
  case 'MW',  inst.sNF = 0.9826 * inst.sNF ./ max(inst.sNF);
  case 'SW',  inst.sNF = 0.2046 * inst.sNF ./ max(inst.sNF);
end

% DClevel_file = '../inst_data/DClevel_parameters_22July2008.mat';
% cris_NF_file = '../inst_data/cris_NF_dct_20080617modified.mat';
% 
% control = load(DClevel_file);
% control.NF = load(cris_NF_file);
% control.NF = control.NF.NF;
% NF = control.NF;
% 
% switch upper(band)
%   case 'LW',  inst.sNF = NF.lw; v_lo = min(NF.vlw); v_hi = max(NF.vlw);
%   case 'MW',  inst.sNF = NF.mw; v_lo = min(NF.vmw); v_hi = max(NF.vmw);
%   case 'SW',  inst.sNF = NF.sw; v_lo = min(NF.vsw); v_hi = max(NF.vsw);
% end
%%%%%% end hack block

% divide the complex spectra by the numerical filter
scene_cxs = scene_cxs ./ inst.sNF;
space_cxs = space_cxs ./ inst.sNF;

% Compute the DC level "normalization factor".  This is required to make the 
% sum of the magnitude integral match the unfiltered ZPD count value.
norm_factor = 1/(inst.df*inst.npts);

% Compute the DC level
[Vdc,F_target_minus_space] = DClevel_model(inst.freq,scene_cxs,space_cxs,norm_factor,modEff,vinst,PGAgain);

% [Vdc,F_target_minus_space] = ...
%    DClevel_model_dt(inst.freq,v_lo, v_hi, scene_cxs,space_cxs,norm_factor,modEff,vinst,PGAgain);

% Compute 2*a2*Vdc*CXS as the "linear" cross-term of the quadratic nonlinearity correction
lincorr_cxs = 2.*a2.*Vdc.*scene_cxs;

% The a2*I^2 "squared" contribution of the quadratic nonlinearity correction is identically zero
sqcorr_cxs = 0;

% Add computed nonlinearity correction to original complex spectrum 
nlcorr_cxs = scene_cxs + lincorr_cxs + sqcorr_cxs;

% ITT equation
% nlcorr_cxs = scene_cxs ./ (1 - 2.*a2.*Vdc);

% optional extra output
if nargout == 2
  extra.band = band;
  extra.iFov = iFov;
  extra.a2 = a2;
  extra.norm_factor = norm_factor;
  extra.modEff = modEff;
  extra.vinst = vinst;
% extra.pgaGain_now = pgaGain_now;
  extra.Vdc = Vdc;
  extra.F_target_minus_space = F_target_minus_space;
end

%%%%% begin hack block
% 
% extra.band = band;
% extra.iFov = iFov;
% extra.a2 = a2;
% extra.norm_factor = norm_factor;
% extra.modEff = modEff;
% extra.vinst = vinst;
% extra.Vdc = Vdc;
% extra.F_target_minus_space = F_target_minus_space;
% 
% [isequaln(extra, extra2), isequaln(nlcorr_cxs, nlcorr_cxs2)]
% 
% if ~isequaln(extra, extra2) || ~isequaln(nlcorr_cxs, nlcorr_cxs2)
%   keyboard
% end
% 
% if strcmp(band, 'MW')
%   extra, extra2
%   plot(inst.freq, pcorr2(nlcorr_cxs), inst.freq, pcorr2(nlcorr_cxs2))
%   legend('new', 'old')
%   keyboard
% end
% 
%%%%% end hack block

