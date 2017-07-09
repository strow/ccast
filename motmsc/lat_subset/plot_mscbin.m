%
% plot_mscbin - equal area zenith stats
%
% *_latbin1 - 16 day good, near nadir
% *_latbin2 - 16 day good, full scan
% *_latbin3 - 16 day good, near nadir plus half-scan
% *_latbin5 - 16 day good, extended nadir
%

d1 = load('airs_latbin1');
d2 = load('cris_latbin1');

% nLat = 20;  dLon = 6;
  nLat = 24;  dLon = 4;
[latB1, lonB1, gtot1, gavg1] = ...
    equal_area_bins(nLat, dLon, d1.slat, d1.slon, d1.slon);

[latB2, lonB2, gtot2, gavg2] = ...
    equal_area_bins(nLat, dLon, d2.slat, d2.slon, d2.slon);

gdiff = gavg2 - gavg1;

% pcolor grid extension
[m,n] = size(gavg1);
gtmp1 = NaN(m+1,n+1);
gtmp2 = NaN(m+1,n+1);
gtmp3 = NaN(m+1,n+1);
gtmp1(1:m, 1:n) = gavg1;
gtmp2(1:m, 1:n) = gavg2;
gtmp3(1:m, 1:n) = gdiff;

% 2d lat and lon arrays
[m,n] = size(gtmp1);
glat = latB1' * ones(1, n);
glon = ones(m,1) * lonB1;

% map boundary setup
latlim = [-90, 90];
lonlim = [-180, 180];

figure(1); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
axesm('mapprojection', 'eqdcylin', ...
      'maplatlimit', latlim, 'maplonlimit', lonlim, ...
      'grid', 'on', 'frame', 'on', 'flinewidth', 1, ...
      'parallellabel', 'on', 'meridianlabel', 'on', ...
      'MLineLocation', 60, 'PLineLocation', 20, ...
      'MLabelParallel', 'south', ...
      'labelformat', 'compass');

surfm(glat, glon, gtmp3)
S = shaperead('landareas','UseGeoCoords',true);
geoshow([S.Lat], [S.Lon],'Color','black');
th = title('CrIS minus AIRS mean equal area longitude bins');
set(th, 'FontSize', 12')
% caxis([-0.25, 0.24])
colorbar
tightmap

figure(2); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
axesm('mapprojection', 'eqdcylin', ...
      'maplatlimit', latlim, 'maplonlimit', lonlim, ...
      'grid', 'on', 'frame', 'on', 'flinewidth', 1, ...
      'parallellabel', 'on', 'meridianlabel', 'on', ...
      'MLineLocation', 60, 'PLineLocation', 20, ...
      'MLabelParallel', 'south', ...
      'labelformat', 'compass')

surfm(glat, glon, gtmp1)
S = shaperead('landareas','UseGeoCoords',true);
geoshow([S.Lat], [S.Lon],'Color','black');
th = title('AIRS mean equal area longitude bins');
set(th, 'FontSize', 12')
colorbar
tightmap

return

figure(3); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
axesm('mapprojection', 'eqdcylin', ...
      'maplatlimit', latlim, 'maplonlimit', lonlim, ...
      'grid', 'on', 'frame', 'on', 'flinewidth', 1, ...
      'parallellabel', 'on', 'meridianlabel', 'on', ...
      'MLineLocation', 60, 'PLineLocation', 20, ...
      'MLabelParallel', 'south', ...
      'labelformat', 'compass')

surfm(glat, glon, gtmp2)
S = shaperead('landareas','UseGeoCoords',true);
geoshow([S.Lat], [S.Lon],'Color','black');
th = title('CrIS mean equal area longitude bins');
set(th, 'FontSize', 12')
colorbar
tightmap

return

% pcolor plot, as a check
figure(2); clf
pcolor(lonB1, latB1, gtmp)
% caxis([-0.5, 0.5])
% caxis([-0.1, 0.1])
title('CrIS minus AIRS equal area relative')
xlabel('longitude')
ylabel('latitude')
shading flat
% load llsmap5
% colormap(llsmap5)
colorbar

