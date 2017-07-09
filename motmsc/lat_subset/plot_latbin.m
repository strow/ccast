%
% plot_latbin - cris minus airs equal area obs
%
% *_latbin1 - 16 day good, near nadir
% *_latbin2 - 16 day good, full scan
% *_latbin3 - 16 day good, near nadir plus half-scan
% *_latbin5 - 16 day good, expanded nadir
%

d1 = load('airs_latbin5');
d2 = load('cris_latbin5');

% nLat = 20;  dLon = 6;
  nLat = 24;  dLon = 4;
[latB1, lonB1, gtot1] = equal_area_bins(nLat, dLon, d1.slat, d1.slon);
[latB2, lonB2, gtot2] = equal_area_bins(nLat, dLon, d2.slat, d2.slon);

% na = length(d1.slat);
% nc = length(d2.slat);
% gmean1 = mean(gtot1(:));
% gdiff = ((na/nc) * gtot2 - gtot1) ./ gmean1;

gmean1 = mean(gtot1(:));
gmean2 = mean(gtot2(:));
grel1 = (gtot1 - gmean1) / gmean1;
grel2 = (gtot2 - gmean2) / gmean2;
gdiff = grel2 - grel1;

% pcolor grid extension
[m,n] = size(gdiff);
gtmp = NaN(m+1,n+1);
gtmp(1:m, 1:n) = gdiff;

% map boundary setup
latlim = [-90, 90];
lonlim = [-180, 180];

% 2d lat and lon arrays
[m,n] = size(gtmp);
glat = latB1' * ones(1, n);
glon = ones(m,1) * lonB1;

figure(1); clf
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
th = title('CrIS minus AIRS equal area relative');
set(th, 'FontSize', 12')
  caxis([-0.25, 0.24])
% caxis([-0.1, 0.1])
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

