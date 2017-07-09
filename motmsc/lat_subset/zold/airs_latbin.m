%
% airs_latbin -- lat and lon bins for AIRS obs
%

% number of latitude bands is 2 x N
% N1 = 40; N2 = 80; N3 = 120; N4 = 160;
  N1 = 10; N2 = 20; N3 = 30; N4 = 40;
vb1 = equal_area_spherical_bands(N1);
vb2 = equal_area_spherical_bands(N2);
vb3 = equal_area_spherical_bands(N3);
vb4 = equal_area_spherical_bands(N4);

% year and path to data
ayear = '/asl/data/airs/L1C/2016';

% specify days of the year
dlist = 111 : 126;  % no missing granules

% xtrack subset
% ixt = 43 : 48;              % 1 near nadir
  ixt =  1 : 90;              % 2 full scan
% ixt = [21:23 43:48 68:70];  % 3 near nadir plus half scan
% ixt = [21:23 68:70];        % 4 half scan only
% ixt = 37 : 54;              % 5 expanded nadir

nxt = length(ixt);  

% cosine exponent
w = 1.1;

% tabulated values
lat = [];
lon = [];
zen = [];

% loop on days of the year
for di = dlist
  
  % loop on L1c granules
  doy = sprintf('%03d', di);
  flist = dir(fullfile(ayear, doy, 'AIRS*L1C*.hdf'));

  for fi = 1 : length(flist);

    afile = fullfile(ayear, doy, flist(fi).name);
    tlat = hdfread(afile, 'Latitude');
    tlon = hdfread(afile, 'Longitude');
    tzen = hdfread(afile, 'satzen');

    tlat = tlat(:, ixt);  tlat = tlat(:);
    tlon = tlon(:, ixt);  tlon = tlon(:);
    tzen = tzen(:, ixt);  tzen = tzen(:);

    iOK = -90 <= tlat & tlat <= 90 & -180 <= tlon & tlon <= 180;
    tlat = tlat(iOK); 
    tlon = tlon(iOK);
    tzen = tzen(iOK); 

    lat = [lat;, tlat];
    lon = [lon;, tlon];
    zen = [zen;, tzen];

    if mod(fi, 10) == 0, fprintf(1, '.'), end
  end
  fprintf(1, '\n')
end

% total good obs count
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

save airs_latbin ayear dlist ixt nobs nsub slat slon szen

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
caxis([-0.5, 0.5])
title('AIRS equal area (count - mean) / mean')
xlabel('longitude')
ylabel('latitude')
shading flat
load llsmap5
colormap(llsmap5)
colorbar

return

%-------------------------
% plot raw latitude bins
%-------------------------
figure(1); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(4,1,1)
histogram(lat, vb1)
title(sprintf('AIRS obs by latitude band, N = %d', N1))
ylabel('obs count')
grid on

subplot(4,1,2)
histogram(lat, vb2)
title(sprintf('AIRS obs by latitude band, N = %d', N2))
ylabel('obs count')
grid on

subplot(4,1,3)
histogram(lat, vb3)
title(sprintf('AIRS obs by latitude band, N = %d', N3))
ylabel('obs count')
grid on

subplot(4,1,4)
histogram(lat, vb4)
title(sprintf('AIRS obs by latitude band, N = %d', N4))
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
Lb5  = -180 :  5 : 180;
Lb10 = -180 : 10 : 180;
Lb20 = -180 : 20 : 180;

% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(3,1,1)
histogram(lon, Lb5)
title('AIRS raw obs by 5 degree longitude band')
ylabel('obs count')
grid on

subplot(3,1,2)
histogram(lon, Lb10)
title('AIRS raw obs by 10 degree longitude band')
ylabel('obs count')
grid on

subplot(3,1,3)
histogram(lon, Lb20)
title('AIRS raw obs by 20 degree longitude band')
ylabel('obs count')
grid on

%----------------------------
% plot subset longitude bins
%-----------------------------
figure(4); clf
Lb5  = -180 :  5 : 180;
Lb10 = -180 : 10 : 180;
Lb20 = -180 : 20 : 180;

% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(3,1,1)
histogram(slon, Lb5)
title('AIRS cos(lat) subset by 5 degree lon band')
ylabel('obs count')
grid on

subplot(3,1,2)
histogram(slon, Lb10)
title('AIRS cos(lat) subset by 10 degree lon band')
ylabel('obs count')
grid on

subplot(3,1,3)
histogram(slon, Lb20)
title('AIRS cos(lat) subset by 20 degree lon band')
ylabel('obs count')
grid on

