%
% plot_subpt - AIRS and CrIS 16 day track map
%

clear all; close all

d1 = load('airs_subpt');
d2 = load('cris_subpt');

% days to plot
nd = 16;

% map boundary setup
latlim = [-90, 90];
lonlim = [-180, 180];

% latlim = [ 10  30]
% lonlim = [-90 -70]

figure(1); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
axesm('mapprojection', 'eqdcylin', ...
      'maplatlimit', latlim, 'maplonlimit', lonlim, ...
      'grid', 'on', 'frame', 'on', 'flinewidth', 1, ...
      'parallellabel', 'on', 'meridianlabel', 'on', ...
      'MLineLocation', 60, 'PLineLocation', 20, ...
      'MLabelParallel', 'south', ...
      'labelformat', 'compass')

% try 6 hour tails
k = floor(length(d1.lat) / (4 * nd))

for i = 1 : length(d1.lat) - k;

  geoshow(d1.lat(i:i+k-1), d1.lon(i:i+k-1), 'Color', 'red', 'linewidth', 2);
  geoshow(d2.lat(i:i+k-1), d2.lon(i:i+k-1), 'Color', 'green', 'linewidth', 2);

  S = shaperead('landareas','UseGeoCoords',true);
  geoshow([S.Lat], [S.Lon],'Color','black');
  th = title(sprintf('AIRS and CrIS %d day track map', nd));
  set(th, 'FontSize', 12')
  legend('map', 'AIRS', 'CrIS', 'location', 'west')
  tightmap

  M(i) = getframe(gcf);
end

save M M

