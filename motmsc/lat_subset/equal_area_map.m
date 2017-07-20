%
% NAME
%   equal_area_map - global map for equal area trapezoids
%
% SYNOPSIS
%   fh = equal_area_map(fn, glat, glon, gval, tstr, cax)
%
% INPUTS
%   fn    - matlab figure number
%   glat  - n+1 vector of latitude boundaries
%   glon  - m+1 vector of longitude boundaries
%   gval  - m x n array of map data values
%   tstr  - map title string
%   cax   - optional color axis
%
% OUTPUT
%   fh    - figure handle
%
% DISCUSSION
%   mainly intended for the grid from equal_area_bins, which has a
%   variable latitude spacing that works well with the eqdcylin map
%   projection
%

function fh = equal_area_map(fn, glat, glon, gval, tstr, cax)

% NaN grid extension
[m, n] = size(gval);
gtmp = NaN(m+1,n+1);
gtmp(1:m, 1:n) = gval;

% 2d lat and lon arrays
glat = glat(:) * ones(1, n+1);
glon = ones(m+1,1) * glon(:)';

% set map boundaries
latlim = [-90, 90];
lonlim = [-180, 180];

fh = figure(fn);  clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
axesm('mapprojection', 'eqdcylin', ...
      'maplatlimit', latlim, 'maplonlimit', lonlim, ...
      'grid', 'on', 'frame', 'on', 'flinewidth', 1, ...
      'parallellabel', 'on', 'meridianlabel', 'on', ...
      'MLineLocation', 60, 'PLineLocation', 20, ...
      'MLabelParallel', 'south', ...
      'labelformat', 'compass')

surfm(glat, glon, gtmp)
S = shaperead('landareas','UseGeoCoords',true);
geoshow([S.Lat], [S.Lon],'Color','black');
th = title(tstr);
set(th, 'FontSize', 12')
if nargin == 6
  caxis(cax);
end
colorbar
tightmap

% % pcolor plot, as a check
% figure(fn+1); clf
% pcolor(lonB1, latB1, gtmp)
% title('CrIS minus AIRS equal area relative')
% xlabel('longitude')
% ylabel('latitude')
% shading flat
% colorbar

