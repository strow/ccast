%
% nextSDR - write to SDR granule buffer
%

function nextSDR(geoTime, nscan, nchanLW, nchanMW, nchanSW)

if length(geoTime) ~= nscan * 34
  error('geoTime length must equal 34 * nscan')
end

% initialize output arrays
scLW = NaN(nchanLW, 9, 34, nscan);
scMW = NaN(nchanMW, 9, 34, nscan);
scSW = NaN(nchanSW, 9, 34, nscan);
scFOR = NaN(34, nscan);
scSDR = NaN(34, nscan);
scTime = NaN(34, nscan)

