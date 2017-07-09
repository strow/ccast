%
% cris_latbin -- lat and lon bins for CrIS obs
%

% number of latitude bands is 2 x N
% N1 = 40; N2 = 80; N3 = 120; N4 = 160;
  N1 = 10; N2 = 20; N3 = 30; N4 = 40;
vb1 = equal_area_spherical_bands(N1);
vb2 = equal_area_spherical_bands(N2);
vb3 = equal_area_spherical_bands(N3);
vb4 = equal_area_spherical_bands(N4);

% allgeo year prefix
ghome = '/asl/data/cris/ccast/daily';

% specify year
year = 2016;
ystr = sprintf('%d', year);

% specify days of the year
dlist = 111 : 126;  % no missing granules

% specify FORs
% iFOR = 15 : 16;       % 1 near nadir
  iFOR =  1 : 30;       % 2 full scan
% iFOR = [8 15 16 23];  % 3 near nadir plus half scan
% iFOR = [8 23];        % 4 half scan only
% iFOR = 13 : 18;       % 5 expanded nadir
nFOR = length(iFOR);

% cosine exponent
w = 1.1;

% all obs in one pot
lat = [];
lon = [];
zen = [];

% loop on days
for doy = dlist
  tmp = datestr(datenum(year,1,1) + doy - 1, 30);
  geofile = fullfile(ghome, ystr, ['allgeo', tmp(1:8), '.mat']);
  d1 = load(geofile);
  lat = cat(3, lat, d1.allgeo.Latitude(:,iFOR,:));
  lon = cat(3, lon, d1.allgeo.Longitude(:,iFOR,:));
  zen = cat(3, zen, d1.allgeo.SatelliteZenithAngle(:,iFOR,:));
end

% get good obs subset
lat = lat(:);
lon = lon(:);
zen = zen(:);
iOK = -90 <= lat & lat <= 90 & -180 <= lon & lon <= 180 & ...
      ~isnan(lat) & ~isnan(lon);
lat = lat(iOK);
lon = lon(iOK);
zen = zen(iOK);
nobs = numel(lat);
fprintf(1, '%d initial good obs\n', nobs)

% get latitude subset as rand < abs(cos(lat))
lat_rad = deg2rad(lat);
ix = rand(nobs, 1) < abs(cos(lat_rad).^w);
slat = lat(ix);
slon = lon(ix);
szen = zen(ix);
nsub = numel(slat);
fprintf(1, '%d obs after subset\n', nsub)

clear d1
save cris_latbin year dlist iFOR nobs nsub slat slon szen

%---------------------------
% plot equal area grid bins
%---------------------------

nLat = 20;  dLon = 6;
[latB, lonB, gtot] = equal_area_trap(nLat, dLon, slat, slon);

gmean = mean(gtot(:));
grel = (gtot - gmean) / gmean;

% pcolor grid extension
[m,n] = size(grel);
gtmp = NaN(m+1,n+1);
gtmp(1:m, 1:n) = grel;

figure(1); clf
pcolor(lonB, latB, gtmp)
% caxis([-0.5, 0.5])
  caxis([-0.1, 0.1])
title('CrIS equal area (count - mean) / mean')
xlabel('longitude')
ylabel('latitude')
shading flat
load llsmap5
colormap(llsmap5)
colorbar

return

% % sanity check with imagesc
% latmid = (latB(1:end-1) + latB(2:end)) / 2;
% lonmid = (lonB(1:end-1) + lonB(2:end)) / 2;
% 
% figure(2); clf
% imagesc(lonmid, latmid, gtot)
% shading flat
% colorbar

%-------------------------
% plot raw latitude bins
%-------------------------
figure(1); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(4,1,1)
histogram(lat, vb1)
title(sprintf('CrIS obs by latitude band, N = %d', N1))
ylabel('obs count')
grid on

subplot(4,1,2)
histogram(lat, vb2)
title(sprintf('CrIS obs by latitude band, N = %d', N2))
ylabel('obs count')
grid on

subplot(4,1,3)
histogram(lat, vb3)
title(sprintf('CrIS obs by latitude band, N = %d', N3))
ylabel('obs count')
grid on

subplot(4,1,4)
histogram(lat, vb4)
title(sprintf('CrIS obs by latitude band, N = %d', N4))
xlabel('latitude')
ylabel('obs count')
grid on

%---------------------------
% plot subset latitude bins
%---------------------------
figure(2); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(4,1,1)
histogram(slat, vb1)
title(sprintf('cos(lat) subset by latitude band, N = %d', N1))
ylabel('obs count')
grid on

subplot(4,1,2)
histogram(slat, vb2)
title(sprintf('cos(lat) subset by latitude band, N = %d', N2))
ylabel('obs count')
grid on

subplot(4,1,3)
histogram(slat, vb3)
title(sprintf('cos(lat) subset by latitude band, N = %d', N3))
ylabel('obs count')
grid on

subplot(4,1,4)
histogram(slat, vb4)
title(sprintf('cos(lat) subset by latitude band, N = %d', N4))
xlabel('latitude')
ylabel('obs count')
grid on

%--------------------------
% plot raw longitude bins
%--------------------------
figure(3); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
Lb5  = -180 :  5 : 180;
Lb10 = -180 : 10 : 180;
Lb20 = -180 : 20 : 180;

subplot(3,1,1)
histogram(lon, Lb5)
title('CrIS raw obs by 5 degree longitude band')
ylabel('obs count')
grid on

subplot(3,1,2)
histogram(lon, Lb10)
title('CrIS raw obs by 10 degree longitude band')
ylabel('obs count')
grid on

subplot(3,1,3)
histogram(lon, Lb20)
title('CrIS raw obs by 20 degree longitude band')
ylabel('obs count')
grid on

%----------------------------
% plot subset longitude bins
%-----------------------------
figure(4); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])

Lb5  = -180 :  5 : 180;
Lb10 = -180 : 10 : 180;
Lb20 = -180 : 20 : 180;

subplot(3,1,1)
histogram(slon, Lb5)
title('CrIS cos(lat) subset by 5 degree lon band')
ylabel('obs count')
grid on

subplot(3,1,2)
histogram(slon, Lb10)
title('CrIS cos(lat) subset by 10 degree lon band')
ylabel('obs count')
grid on

subplot(3,1,3)
histogram(slon, Lb20)
title('CrIS cos(lat) subset by 20 degree lon band')
ylabel('obs count')
grid on
