
% loop test of using Bomem procedures to calculate ICT

dsrc = '/asl/data/cris/mott/2010/09/06mit';

dlist = dir(sprintf('%s/RDR*.mat', dsrc));

% loop on MIT RDR matlab files

for i = 1 : length(dlist)

% for i = 3

  fmit = [dsrc, '/', dlist(i).name];

  % load the MIT data, defines structures d1 and m1
  load(fmit)

  if ~isfield(d1.packet, 'TempCoeffs')
    fprintf(1, '%3d field TempCoeffs not found\n', i)
    continue
  end

  try
    TempReadings = d1.data.sci.Temp;
    TempCoeffs = d1.packet.TempCoeffs;

    AlgoParams.ICT_PRT1_Bias = 0;
    AlgoParams.ICT_PRT2_Bias = 0;
    AlgoParams.CelciusToKelvinOffset = 273.15;

    % possible work around for record-size problems
   jx = ztail(TempReadings.time);

    Temperature.ICT_1 = ConvertICT_Temperature(...
      TempReadings.ICT_1.Pts(1:jx), ...
      TempReadings.ICT_LowCalibResis.Pts(1:jx), ...
      TempReadings.ICT_HighCalibResis.Pts(1:jx), ...
      TempReadings.IE_CCA_CalibResTemp.Pts(1:jx), ...
      TempCoeffs.ICT_PRT1, TempCoeffs, ...
      AlgoParams.ICT_PRT1_Bias, AlgoParams.CelciusToKelvinOffset);

    Temperature.ICT_2 = ConvertICT_Temperature(...
      TempReadings.ICT_2.Pts(1:jx), ...
      TempReadings.ICT_LowCalibResis.Pts(1:jx), ...
      TempReadings.ICT_HighCalibResis.Pts(1:jx), ...
      TempReadings.IE_CCA_CalibResTemp.Pts(1:jx), ...
      TempCoeffs.ICT_PRT2, TempCoeffs, ...
      AlgoParams.ICT_PRT2_Bias, AlgoParams.CelciusToKelvinOffset);

  catch me
     fprintf(1, 'error processing file %s\n', dlist(i).name)
     continue
  end

   fprintf(1, '%3d ICT_1=%f ICT_2=%f\n', ...
           i, Temperature.ICT_1, Temperature.ICT_2);

end

