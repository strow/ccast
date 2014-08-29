function [ ICT_Temperature ] = ConvertICT_Temperature(ICT, ICT_LowCal, ICT_HighCal, ICT_CalRTD, ICT_PRT, TempCoeffs, ICT_Bias, CelciusToKelvinOffset);

% Convert internal calibration target temperature readings to engineering units.
%
% Description:
%    Convert ICT temperature readings using dual calibration resistor technique.
%
% Usage:
%   [ ICT_Temperature ] = ConvertICT_Temperature(...
%                         ICT, ICT_LowCal, ICT_HighCal, ICT_CalRTD, ...
%                         ICT_PRT, TempCoeffs, ICT_Bias, CelciusToKelvinOffset);
%
% Input:
%   ICT : Raw ICT temperature readings [structure, d.u.].
%   ICT_LowCal : Low calibration resistor readings [structure, d.u.].
%   ICT_HighCal : High calibration resistor readings [structure, d.u.].
%   ICT_CalRTD : RTD calibration resistor readings [structure, d.u.].
%   ICT_PRT : ICT PRT coefficients [structure].
%   TempCoeffs : Coefficients used for temperature conversion [structure].
%   ICT_Bias : ICT temperature bias [scalar, K].
%   CelciusToKelvinOffset : Offset for Celcius to Kelvin conversion [scalar, K].
%
% Output:
%   ICT_Temperature : Temperature in engineering units [scalar, K].
%

% Authors :
%   Martin Levert (MLV), Simon Dubé (SDB).
%
% Change Record:
%   Date         By   Description
%   13-Dec-2002  SDB  Updated to support most recent calibration equations.
%   13-Nov-2002  MLV  First version creation.
%
% COPYRIGHT (C) ABB INC
%
%  ABB Inc.,
%  Analytical and Advanced Solutions
%  585, Boul. Charest Est, bureau 300
%  Quebec, (Quebec) G1K 9H4 CANADA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Coefficients from Engineering packet
%
R0_PRT = ICT_PRT.Ro;
A_PRT = ICT_PRT.A;
B_PRT = ICT_PRT.B;

R0_LowCal  = TempCoeffs.ICT_LowCalibResis.Ro;
A_LowCal   = TempCoeffs.ICT_LowCalibResis.A;

R0_HighCal = TempCoeffs.ICT_HighCalibResis.Ro;
A_HighCal  = TempCoeffs.ICT_HighCalibResis.A;

RO_CalRTD  = TempCoeffs.ICT_IE_CCA_CalibResis.Ro;
A_CalRTD  = TempCoeffs.ICT_IE_CCA_CalibResis.A;

% Compute Temperature Corrected Calibration Resistor Values
%

R_LowCal = R0_LowCal * ( 1 + A_LowCal * ( (R0_HighCal - R0_LowCal)/A_CalRTD ) ...
    * ( (ICT_CalRTD - ICT_LowCal) ./ (ICT_HighCal - ICT_LowCal) ) );

R_HighCal = R0_HighCal * ( 1 + A_HighCal * ( (R0_HighCal - R0_LowCal)/A_CalRTD ) ...
    * ( (ICT_CalRTD - ICT_LowCal) ./ (ICT_HighCal - ICT_LowCal) ) );

% Compute PRT Resistance Value from Measurements
%
R_PRT = R_LowCal + (R_HighCal - R_LowCal) .* ( (ICT - ICT_LowCal) ./ (ICT_HighCal - ICT_LowCal) );

% Compute ICT temperature
%
% Solve: R_PRT = R0_PRT * (1 + A_PRT * T_PRT + B_PRT * T_PRT^2) for T_PRT
% (Taylor expansion is used)
%
W = ( R0_PRT * B_PRT * (R0_PRT - R_PRT) ) / ( R0_PRT * A_PRT )^2;

T_PRT = -( (R0_PRT - R_PRT) / (R0_PRT * A_PRT) ) .* (1 + 2*W + 6*W.^2 + 20*W.^3);

% Compute average temperature
%
T_PRT_Avg = mean(T_PRT);

% Convert from Celcius to Kelvin
%
ICT_Temperature = T_PRT_Avg + ICT_Bias + CelciusToKelvinOffset;

