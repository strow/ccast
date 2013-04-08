
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

% Construct control structure if not input.  This includes numerical filter data, instrument background 
% fraction parameter, and ifr modulation efficiency.
if nargin <= 6
  control = load('DClevel_parameters_22July2008.mat'); 
  control.NF = load('NF_dct_20080617modified.mat');
  control.NF = control.NF.NF;
end
NF = control.NF;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Define/compute a2 values
%
% These are a2 values derived from minimizing ECT view residuals from TVAC3 MN1 and 
% are the values contained in a2_coeffs.optJAN2009 in a2_UW_refined_27Jan2009.mat.
%
% Although in different units, these correspond to the version 32 Engineering Packet values used in IDPS/ADL processing.
%
%              FOV =     1         2         3         4         5         6          7        8         9
a2_tvac3_mn1_ect.lw = [6.6814    6.3409    5.9984    9.5624    7.7635    7.6739     5.916    5.8978    7.9171  ]'/1e7;
a2_tvac3_mn1_ect.mw = [2.7352    6.6925   11.567     5.6065    6.9917    1.6121    17.954   12.393     0.99827 ]'/1e7;
a2_tvac3_mn1_ect.sw = [  0         0         0         0         0         0          0        0         0     ]'/1e7;
%
% Also define PGA gain values corresponding to TVAC3 MN1.  These values where hard-coded in 
% NLAPP.m ($Id: ccast_NLAPP.m,v 1.16 2009/03/03 16:07:59 joet Exp $) as variables MN1lw_gainsTV3, 
% MN1mw_gainsTV3, and MN1sw_gainsTV3;
%
tmp = [3.3200 3.6500 4.0200 4.4200 4.8800 5.3600 5.9000 6.4900 7.1400 7.8600 8.6400 9.5100 10.4900 11.5400 12.6900 13.9600];
pgaGain_tvac3_mn1.lw = tmp([9 7 9 7 4 7 8 7 10]+1)';
tmp = [3.0100 3.3100 3.6400 4.0100 4.4200 4.8600 5.3500 5.8600 6.4800 7.1300 7.8400 8.6200 9.5100 10.4600 11.5100 12.6600];
pgaGain_tvac3_mn1.mw = tmp([8 8 9 7 6 7 10 8 10]+1)';
tmp = [3.0100 3.3100 3.6400 4.0100 4.4200 4.8600 5.3500 5.8600 6.4800 7.1300 7.8400 8.6200 9.5100 10.4600 11.5100 12.6600];
pgaGain_tvac3_mn1.sw = tmp([6 4 6 4 3 5 5 5 8]+1)';
%
% Scale the above a2 values for use with the current data based on the current PGA Gain values.  Pull out PGA gains:
%
pgaGain_now.lw = PGA_Gain.Band(1).map(PGA_Gain.Band(1).Setting+1);
pgaGain_now.mw = PGA_Gain.Band(2).map(PGA_Gain.Band(2).Setting+1);
pgaGain_now.sw = PGA_Gain.Band(3).map(PGA_Gain.Band(3).Setting+1);
%
% And do the scaling
%
a2_now.lw = a2_tvac3_mn1_ect.lw .* pgaGain_tvac3_mn1.lw ./ pgaGain_now.lw;
a2_now.mw = a2_tvac3_mn1_ect.mw .* pgaGain_tvac3_mn1.mw ./ pgaGain_now.mw;
a2_now.sw = a2_tvac3_mn1_ect.sw .* pgaGain_tvac3_mn1.sw ./ pgaGain_now.sw;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% Preliminary scale factors, 28-Feb, DCT, based on DM and Fov-2-Fov analysis
%sf = [1.3000 1.2300 0.9500 1.2100 1      0.7800 1.0900 2.5000 1.7000];
%a2_now.lw = a2_now.lw .* sf';
%sf = [0      1.4300 1.3100 0.5000 0.8300 0      2.1500 1.6800 0];
%a2_now.mw = a2_now.mw .* sf';


% DCT 19-Nov-2012
% a2 scale factors derived from analysis of FOV-2-FOV differences.  These scale factors are ratios of 
% a2 values derived from analysis of IDPS/CSPP data, and are applied here to the CCAST values.
sf = [1.166 1.0346 0.94156 1.2843 1.0697 0.95456 1.3812 1.6973 1.3745];
a2_now.lw = a2_now.lw .* sf';
sf = [1.0081 1.4049 1.1205 1.1543 1.1414 1.4764 2.1252 1.7396 1.0003];
a2_now.mw = a2_now.mw .* sf';


% Apply additional overall (FOV independent) emperical scale factors
% global A2_SCALE_FACTOR
A2_SCALE_FACTOR = 1;
a2_now.lw = a2_now.lw * A2_SCALE_FACTOR;
a2_now.mw = a2_now.mw * A2_SCALE_FACTOR;
a2_now.sw = a2_now.sw * A2_SCALE_FACTOR;

%
% Define limits for spectral integrals, reduction factors, and # normal mode spectral points.  
% Divide the complex spectra by the numerical filter.  Also pull out values of a2, kfac, and 
% modulation efficiency for this FOV, this band.
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
    kfac = control.DClevel_parameters.kfac.lw(iFov);

  case 'MW'
    reduction_factor = 20;
    npoints_nm = NF.mw_npoints_nm;
    v_lo = min(NF.vmw); v_hi = max(NF.vmw); 
    scene_cxs = scene_cxs./NF.mw;
    space_cxs = space_cxs./NF.mw;
    a2 = a2_now.mw(iFov);
    modEff = control.DClevel_parameters.ModEff.mw(iFov);
    kfac = control.DClevel_parameters.kfac.mw(iFov);

  case 'SW'
    reduction_factor = 26;
    npoints_nm = NF.sw_npoints_nm;
    v_lo = min(NF.vsw); v_hi = max(NF.vsw);
    scene_cxs = scene_cxs./NF.sw;
    space_cxs = space_cxs./NF.sw;
    a2 = a2_now.sw(iFov);
    modEff = control.DClevel_parameters.ModEff.sw(iFov);
    kfac = control.DClevel_parameters.kfac.sw(iFov);

end

%
% Compute the DC level "normalization factor".  This is required to make the
% sum of the magnitude integral match the unfiltered ZPD count value.
%
norm_factor = 1/(reduction_factor*npoints_nm);

%
% Compute the DC level
%
Vdc  = DClevel_model(v,v_lo,v_hi,scene_cxs,space_cxs,norm_factor,modEff,kfac);

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


if nargout == 2
  extra.band = band;
  extra.iFov = iFov;
  extra.a2 = a2;
  extra.norm_factor = norm_factor;
  extra.kfac = kfac;
  extra.modEff = modEff;
  extra.control = control;
  extra.a2_now = a2_now;
  extra.pgaGain_now = pgaGain_now;
  extra.a2_tvac3_mn1_ext = a2_tvac3_mn1_ect;
  extra.pgaGain_tvac3_mn1 = pgaGain_tvac3_mn1;
  extra.Vdc = Vdc;
end
