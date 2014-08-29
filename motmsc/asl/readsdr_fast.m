%
% read a specific set of CrIS SDR fields
%

function pd = readsdr_rawpd(hfile);

pd = struct;

pd.MeasuredLaserWavelength = ...
  h5read(hfile, '/All_Data/CrIS-SDR_All/MeasuredLaserWavelength');

pd.ResamplingLaserWavelength = ...
  h5read(hfile, '/All_Data/CrIS-SDR_All/ResamplingLaserWavelength');

