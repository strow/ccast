
function T = cris_calc_instrument_temps_CCAST(Temp,TempCoeffs,Nkeep)

%
% function T = cris_calc_instrument_temps_CCAST(Temp,TempCoeffs,Nkeep)
%
% Convert instrument temperature readings from ADC counts to Temp (Kelvin)
%
% INPUTS
%  Temp:        structure of 8-sec-science data, as read with the MIT LL RDR reader in d1.data.sci.Temp.Temp (NOTE the two "Temp"s)
%  TempCoeffs:  structure 4 minute engineering packet data, as read with the MIT LL RDR reader in d1.packet.TempCoeffs
%  Nkeep:       Number of 8-sec-science elements to keep.  See further info for Nkeep in cris_ICT_countsToK_CCAST.m
%
% OUTPUTS
%   Temperature (K) of various optical/structural elements [Nkeep x 1]
%   T.OMA_structure_input_1
%   T.OMA_structure_input_2
%   T.OMA_structure_input     (mean of OMA_structure_input_1 and OMA_structure_input_2)
%   T.SSM_scan_mirror
%   T.beamsplitter_1
%   T.SSM_scan_mirror_baffle
%
% Sample call:
%       Nkeep = ztail(d1.data.sci.Temp.Temp.OMA_1)
%       instr_temps = cris_calc_instrument_temps_CCAST(d1.data.sci.Temp.Temp,d1.packet.TempCoeffs,Nkeep)
%
% adapted from cris_calc_instrument_temps.m on 4 Nov 2011 by DCT to use MIT LL reader format inputs
% created by JKTaylor, SSEC, University of Wisconsin-Madison 21-May-2008
% $Id: cris_calc_instrument_temps.m,v 1.8 2009/08/06 14:53:37 joet Exp $
%

% 
% 4-min-eng packet variables used:
% Original code name                                xml name and v27 value                                                          MIT reader name and v27 value
% eng_OMA_StructureTemperature1Coeff_intercept      four_min_eng.var.eng_OMA_StructureTemperature1Coeff_intercept.value, 37.2045    d1.packet.TempCoeffs.OMA_1.Intercept, 37.2045
% eng_OMA_StructureTemperature1Coeff_slope          four_min_eng.var.eng_OMA_StructureTemperature1Coeff_slope.value, 0.0099         d1.packet.TempCoeffs.OMA_1.Slope, 0.0099
% eng_OMA_StructureTemperature2Coeff_intercept      four_min_eng.var.eng_OMA_StructureTemperature2Coeff_intercept.value, 37.2045    d1.packet.TempCoeffs.OMA_2.Intercept, 37.2045
% eng_OMA_StructureTemperature2Coeff_slope          four_min_eng.var.eng_OMA_StructureTemperature2Coeff_slope.value, 0.0099         d1.packet.TempCoeffs.OMA_2.Slope, 0.0099
% eng_ScanMirror_TemperatureCoeff_intercept         four_min_eng.var.eng_ScanMirror_TemperatureCoeff_intercept.value, 300.6600      d1.packet.TempCoeffs.ScanMirror.Intercept, 300.6600
% eng_ScanMirror_TemperatureCoeff_slope             four_min_eng.var.eng_ScanMirror_TemperatureCoeff_slope.value, 0.0063            d1.packet.TempCoeffs.ScanMirror.Slope, 0.0063
% eng_Beamsplitter_Temperature1Coeff_intercept      four_min_eng.var.eng_Beamsplitter_Temperature1Coeff_intercept.value, 37.2045    d1.packet.TempCoeffs.Beamsplitter.Intercept, 37.2045
% eng_Beamsplitter_Temperature1Coeff_slope          four_min_eng.var.eng_Beamsplitter_Temperature1Coeff_slope.value, 0.0099         d1.packet.TempCoeffs.Beamsplitter.Slope, 0.0099
% eng_ScanBaffle_TemperatureCoeff_intercept         four_min_eng.var.eng_ScanBaffle_TemperatureCoeff_intercept.value, 300.6600      d1.packet.TempCoeffs.ScanBaffle.Intercept, 300.6600
% eng_ScanBaffle_TemperatureCoeff_slope             four_min_eng.var.eng_ScanBaffle_TemperatureCoeff_slope.value, 0.0063            d1.packet.TempCoeffs.ScanBaffle.Slope, 0.0063
%
% 8-sec science packet variables used:
% Original code name                                MIT reader name and sample value
% sci_OMA_structure_input_temp_1                    d1.data.sci.Temp.Temp.OMA_1, -2978
% sci_OMA_structure_input_temp_2                    d1.data.sci.Temp.Temp.OMA_2, -2968
% sci_SSM_scan_mirror_temp                          d1.data.sci.Temp.Temp.ScanMirror, -3150
% sci_beamsplitter_temp_1                           d1.data.sci.Temp.Temp.Beamsplitter, -2958
% sci_SSM_scan_mirror_baffle_temp                   d1.data.sci.Temp.Temp.ScanBaffle, -3140
%

T.OMA_structure_input_1 = TempCoeffs.OMA_1.Intercept + TempCoeffs.OMA_1.Slope * Temp.OMA_1(1:Nkeep);
T.OMA_structure_input_2 = TempCoeffs.OMA_2.Intercept + TempCoeffs.OMA_2.Slope * Temp.OMA_2(1:Nkeep);
T.OMA_structure_input = (T.OMA_structure_input_1 + T.OMA_structure_input_2)/2;
T.SSM_scan_mirror = TempCoeffs.ScanMirror.Intercept + TempCoeffs.ScanMirror.Slope * Temp.ScanMirror(1:Nkeep);
T.beamsplitter_1 = TempCoeffs.Beamsplitter.Intercept + TempCoeffs.Beamsplitter.Slope * Temp.Beamsplitter(1:Nkeep);
T.SSM_scan_mirror_baffle = TempCoeffs.ScanBaffle.Intercept + TempCoeffs.ScanBaffle.Slope * Temp.ScanBaffle(1:Nkeep);

