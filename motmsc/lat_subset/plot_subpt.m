%
% plot_subpt - AIRS and CrIS 16 day track map
%

d1 = load('airs_subpt');
d2 = load('cris_subpt');

% days to plot
nd = 16;

% map boundary setup
latlim = [-90, 90];
lonlim = [-180, 180];

% latlim = [ 10  30]
% lonlim = [-100 -70]

figure(1); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
axesm('mapprojection', 'eqdcylin', ...
      'maplatlimit', latlim, 'maplonlimit', lonlim, ...
      'grid', 'on', 'frame', 'on', 'flinewidth', 1, ...
      'parallellabel', 'on', 'meridianlabel', 'on', ...
      'MLineLocation', 60, 'PLineLocation', 20, ...
      'MLabelParallel', 'south', ...
      'labelformat', 'compass')

k1 = floor(length(d1.lat)/16); k1 = nd * k1;
k2 = floor(length(d2.lat)/16); k2 = nd * k2;

geoshow(d1.lat(1:k1), d1.lon(1:k1), 'Color', 'red', 'linewidth', 2);
geoshow(d2.lat(1:k2), d2.lon(1:k2), 'Color', 'green', 'linewidth', 2);

S = shaperead('landareas','UseGeoCoords',true);
geoshow([S.Lat], [S.Lon],'Color','black');
th = title(sprintf('AIRS and CrIS %d day track map', nd));
set(th, 'FontSize', 12')
legend('map', 'AIRS', 'CrIS', 'location', 'west')
tightmap

