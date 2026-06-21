
% Basic test of using Bomem procedures to calculate ICT

% original data source for readers
dsrc  = '/asl/data/cris/Proxy/2010/09/06';

% select mat files from timestamp in RDR filenames
% rid  = 'd20100906_t0706030';
rid  = 'd20100906_t0330042';
% rid  = 'd20100906_t0610033';

% MIT matlab RDR data
dmit = '/asl/data/cris/mott/2010/09/06mit';
rmit = ['RDR_', rid, '.mat'];
fmit = [dmit, '/', rmit];

% load the MIT data, defines structures d1 and m1
load(fmit)

TempReadings = d1.data.sci.Temp;

TempCoeffs = d1.packet.TempCoeffs;

AlgoParams.ICT_PRT1_Bias = 0;
AlgoParams.ICT_PRT2_Bias = 0;
AlgoParams.CelciusToKelvinOffset = 273.15;

Temperature.ICT_1 = ConvertICT_Temperature(...
    TempReadings.ICT_1.Pts(1:60), ...
    TempReadings.ICT_LowCalibResis.Pts(1:60), ...
    TempReadings.ICT_HighCalibResis.Pts(1:60), ...
    TempReadings.IE_CCA_CalibResTemp.Pts, ...
    TempCoeffs.ICT_PRT1, TempCoeffs, ...
    AlgoParams.ICT_PRT1_Bias, AlgoParams.CelciusToKelvinOffset);

Temperature.ICT_2 = ConvertICT_Temperature(...
    TempReadings.ICT_2.Pts(1:60), ...
    TempReadings.ICT_LowCalibResis.Pts(1:60), ...
    TempReadings.ICT_HighCalibResis.Pts(1:60), ...
    TempReadings.IE_CCA_CalibResTemp.Pts, ...
    TempCoeffs.ICT_PRT2, TempCoeffs, ...
    AlgoParams.ICT_PRT2_Bias, AlgoParams.CelciusToKelvinOffset);

