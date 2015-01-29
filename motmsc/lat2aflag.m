%
% NAME
%   lat2aflag - flag ascending latitudes
%
% SYNOPSIS
%   aflag = lat2aflag(lat)
%
% INPUT
%   lat    - latitude, in time order
%   
% OUTPUT
%   aflag  - 1 = ascending, 0 = descending, NaN = bad lat value
%

function aflag = lat2aflag(lat)

lat = lat(:);
n = length(lat);
aflag = ones(n,1) * NaN;
iok = -100 < lat & lat < 100 & ~isnan(lat);
if sum(iok) > 1
  d = diff(lat(iok)) > 0;
  aflag(iok) = [d; d(end)];
end

