
% wrapper for the Bomem ICT temp procedure

function [ict1, ict2] = getICTtemp(d1)

addpath bomem

% initialize outputs
ict1 = []; ict2 = [];

% check for engineering data
if ~isfield(d1.packet, 'TempCoeffs')
  fprintf(1, 'field TempCoeffs not found in d1.packet\n', i)
  return
end

% use the Bomem structure names
TempReadings = d1.data.sci.Temp;
TempCoeffs = d1.packet.TempCoeffs;

% set the remaining parameters
AlgoParams.ICT_PRT1_Bias = 0;
AlgoParams.ICT_PRT2_Bias = 0;
AlgoParams.CelciusToKelvinOffset = 273.15;

% possible work around for record-size problems in d1
jx = ztail(TempReadings.time);

ict1 = ConvertICT_Temperature(...
  TempReadings.ICT_1.Pts(1:jx), ...
  TempReadings.ICT_LowCalibResis.Pts(1:jx), ...
  TempReadings.ICT_HighCalibResis.Pts(1:jx), ...
  TempReadings.IE_CCA_CalibResTemp.Pts(1:jx), ...
  TempCoeffs.ICT_PRT1, TempCoeffs, ...
  AlgoParams.ICT_PRT1_Bias, AlgoParams.CelciusToKelvinOffset);

ict2 = ConvertICT_Temperature(...
  TempReadings.ICT_2.Pts(1:jx), ...
  TempReadings.ICT_LowCalibResis.Pts(1:jx), ...
  TempReadings.ICT_HighCalibResis.Pts(1:jx), ...
  TempReadings.IE_CCA_CalibResTemp.Pts(1:jx), ...
  TempCoeffs.ICT_PRT2, TempCoeffs, ...
  AlgoParams.ICT_PRT2_Bias, AlgoParams.CelciusToKelvinOffset);

