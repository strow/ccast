
function OUT = ICT_countsToK(Temp,TempCoeffs,Nkeep)

%
% function OPUT = ICT_countsToK(Temp,TempCoeffs,Nkeep)
%
% Convert CrIS ICT Thermistor ADC count values to a calibrated thermistor Temp [K]
% 
% Inputs:
%       Temp:           structure of CrIS 8-second science packet data, as read with 
%                       the MIT LL RDR h5 reader in d1.data.sci.Temp
%       TempCoeffs:     structure of CrIS 4 minute engineering packet data, as read with 
%                       the MIT LL RDR reader in d1.packet.TempCoeffs
%       Nkeep:          This is the number of elements of the 8-sec-science packet variables 
%                       that are used in the ICT temperature calculations, and also the length
%                       of  the output variables.  This number is specified as an input because 
%                       there are typically many fill-value (zero) elements in the 8-sec-science 
%                       packet variables (and also because the variable "d1.data.sci.Temp.IE_CCA_CalibResTemp.Pts" 
%                       does not always seem to have the same number of non-zero elements as all the 
%                       other 8-sec-science packet variables).  Nkeep should be equal to the number of 
%                       scan lines in a granule and the number of valid 8-sec-science packets, and can 
%                       be computed e.g. with ztail(d1.data.sci.Temp.ICT_1.Pts).
%
% Outputs:
%       OUT.T_PRT1      Temperature (K) of ICT PRT1 [Nkeep x 1]
%       OUT.T_PRT2      Temperature (K) of ICT PRT2 [Nkeep 1 1]
%       OUT.dnum        Malab datenumbers of the 8-sec sci packets (computed from Temp.time) [Nkeep x 1]
%
% Sample call:  
%       Nkeep = ztail(d1.data.sci.Temp.ICT_1.Pts)
%       ict_temps = ICT_countsToK(d1.data.sci.Temp,d1.packet.TempCoeffs,Nkeep)
%
% History:
%   Bug in calculation of t_CCA found by LAB and fixed by DCT, 11-June-2014
%   Renamed ICT_countsToK.m and adapted by DCT on 4 Nov 2011 to work with MIT reader packets.
%   ICT_countsToK_TVAC3 created by JKT, SSEC, University of Wisconsin-Madison
%   based on code supplied by D. Mooney, MIT
%   $Id: cris_ICT_countsToK_TVAC3.m,v 1.2 2009/08/06 16:19:53 joet Exp $
%

%
% 4-minute-engineering packet variables used in this function:
%  Original code name                          xml name and v27 value                                                        MIT reader name and v27 value
%  eng_ICTHighRange_CalibrationResistor_Ro     four_min_eng.var.eng_ICTHighRange_CalibrationResistor_Ro.value, 239.7063      d1.packet.TempCoeffs.ICT_HighCalibResis.Ro, 239.7063
%  eng_ICTHighRange_CalibrationResistor_a      four_min_eng.var.eng_ICTHighRange_CalibrationResistor_a.value,0               d1.packet.TempCoeffs.ICT_HighCalibResis.A, 0
%  eng_ICTLowRange_CalibrationResistor_Ro      four_min_eng.var.eng_ICTLowRange_CalibrationResistor_Ro.value, 199.7515       d1.packet.TempCoeffs.ICT_LowCalibResis.Ro, 199.7515
%  eng_ICTLowRange_CalibrationResistor_a       four_min_eng.var.eng_ICTLowRange_CalibrationResistor_a.value, 0               d1.packet.TempCoeffs.ICT_LowCalibResis.A, 0
%  eng_IECCA_ResistorTemperature_Ro            four_min_eng.var.eng_IECCA_ResistorTemperature_Ro.value, 200                  d1.packet.TempCoeffs.ICT_IE_CCA_CalibResis.Ro, 200
%  eng_IECCA_ResistorTemperature_a             four_min_eng.var.eng_IECCA_ResistorTemperature_a.value, 0.0040                d1.packet.TempCoeffs.ICT_IE_CCA_CalibResis.A, 0.0040
%  eng_ICTPRT1_Coeff_Ro                        four_min_eng.var.eng_ICTPRT1_Coeff_Ro.value, 200.2423                         d1.packet.TempCoeffs.ICT_PRT1.Ro, 200.2423
%  eng_ICTPRT1_Coeff_a                         four_min_eng.var.eng_ICTPRT1_Coeff_a.value, 0.0040                            d1.packet.TempCoeffs.ICT_PRT1.A, 0.0040
%  eng_ICTPRT1_Coeff_b                         four_min_eng.var.eng_ICTPRT1_Coeff_b.value, -6.5213e-07                       d1.packet.TempCoeffs.ICT_PRT1.B, -6.5213e-07
%  eng_ICTPRT2_Coeff_Ro                        four_min_eng.var.eng_ICTPRT2_Coeff_Ro.value, 199.7829                         d1.packet.TempCoeffs.ICT_PRT2.Ro, 199.7829
%  eng_ICTPRT2_Coeff_a                         four_min_eng.var.eng_ICTPRT2_Coeff_a.value, 0.0040                            d1.packet.TempCoeffs.ICT_PRT2.A, 0.0040
%  eng_ICTPRT2_Coeff_b                         four_min_eng.var.eng_ICTPRT2_Coeff_b.value, -6.0923e-07                       d1.packet.TempCoeffs.ICT_PRT2.B, -6.0923e-07
%
% 8-SEC SCIENCE PACKET VARS USED IN FUNCTION
%  Original code name                          MIT reader name and sample value
%  sci_high_range_cal_resistor                 d1.data.sci.Temp.ICT_HighCalibResis.Pts, 1
%  sci_low_range_cal_resistor                  d1.data.sci.Temp.ICT_LowCalibResis.Pts, 25
%  sci_IE_CCA_cal_resistor_temp                d1.data.sci.Temp.IE_CCA_CalibResTemp.Pts, 6
%  sci_ICT_temp_1                              d1.data.sci.Temp.ICT_1.Pts, 21
%  sci_ICT_temp_2                              d1.data.sci.Temp.ICT_2.Pts, 21
%

resp0 = (TempCoeffs.ICT_HighCalibResis.Ro - TempCoeffs.ICT_LowCalibResis.Ro) ./ (Temp.ICT_HighCalibResis.Pts(1:Nkeep) - Temp.ICT_LowCalibResis.Pts(1:Nkeep));
R_CCA = TempCoeffs.ICT_LowCalibResis.Ro + resp0 .* (Temp.IE_CCA_CalibResTemp.Pts(1:Nkeep) - Temp.ICT_LowCalibResis.Pts(1:Nkeep));
%t_CCA = (R_CCA - TempCoeffs.ICT_LowCalibResis.Ro) / (TempCoeffs.ICT_IE_CCA_CalibResis.A * TempCoeffs.ICT_IE_CCA_CalibResis.Ro);

%% Above calculation of t_CCA should be:
t_CCA = (R_CCA - TempCoeffs.ICT_IE_CCA_CalibResis.Ro) / (TempCoeffs.ICT_IE_CCA_CalibResis.A * TempCoeffs.ICT_IE_CCA_CalibResis.Ro);

% Correct the two calibration resistors for temperature
RH = TempCoeffs.ICT_HighCalibResis.Ro * (1 + TempCoeffs.ICT_HighCalibResis.A * t_CCA);
RL = TempCoeffs.ICT_LowCalibResis.Ro * (1 + TempCoeffs.ICT_LowCalibResis.A * t_CCA);

resp = (RH-RL) ./ (Temp.ICT_HighCalibResis.Pts(1:Nkeep) - Temp.ICT_LowCalibResis.Pts(1:Nkeep));

% Compute the resistance of the two PRTs 
R_PRT1 = RL + resp .* (Temp.ICT_1.Pts(1:Nkeep) - Temp.ICT_LowCalibResis.Pts(1:Nkeep));
R_PRT2 = RL + resp .* (Temp.ICT_2.Pts(1:Nkeep) - Temp.ICT_LowCalibResis.Pts(1:Nkeep));

% solve the quadratic R=R0*(1+At+Bt^2)=c+bt+at^2 for PRT1
c = TempCoeffs.ICT_PRT1.Ro - R_PRT1;
b = TempCoeffs.ICT_PRT1.Ro * TempCoeffs.ICT_PRT1.A;
a = TempCoeffs.ICT_PRT1.Ro * TempCoeffs.ICT_PRT1.B;
w = a*c/b^2;
T_PRT1 = -c/b.*(1+w+2*w.^2+5*w.^3);
% T_PRT1 = -2.*c./(1+sqrt(1-4.*a.*c./b./b))./b:
OUT.T_PRT1 = T_PRT1 + 273.15;

% solve the quadratic R=R0*(1+At+Bt^2)=c+bt+at^2 for PRT2
c = TempCoeffs.ICT_PRT2.Ro - R_PRT2;
b = TempCoeffs.ICT_PRT2.Ro * TempCoeffs.ICT_PRT2.A;
a = TempCoeffs.ICT_PRT2.Ro * TempCoeffs.ICT_PRT2.B;
w = a*c/b^2;
T_PRT2 = -c/b.*(1+w+2*w.^2+5*w.^3);
% T_PRT2 = -2.*c./(1+sqrt(1-4.*a.*c./b./b))./b:
OUT.T_PRT2 = T_PRT2 + 273.15;

% Also return the time for these 8-sec-sci packets.  These are maltab datenumbers.
OUT.dnum = Temp.time(1:Nkeep) + datenum(1958,1,1);
