%
% cris_obslist -- lat and lon bins for CrIS obs
%

addpath ./time

% allgeo year prefix
ghome = '/asl/data/cris/ccast/daily';

% specify year
year = 2016;
ystr = sprintf('%d', year);

% days of the year
  dlist = 111 : 126;  % d1, 2016 16 day all good
% dlist = 118 : 133;  % d2, 2016 16 day all good
% dlist = 101 : 116;  % d3, 2016 CrIS-only good span 1
% dlist = 117 : 132;  % d4, 2016 CrIS-only good span 2

% CrIS scan spec
% iFOR = 15 : 16;       % s1, near nadir
  iFOR =  1 : 30;       % s2, full scan
% iFOR = [8 15 16 23];  % s3, near nadir plus half scan
% iFOR = [8 23];        % s4, half scan only
% iFOR = 13 : 18;       % s5, expanded nadir
nFOR = length(iFOR);

% specify FOVs
  iFOV = 1 : 9;
% iFOV = [3 6 9];
% iFOV = 9;
nFOV = length(iFOV);

% cosine exponent
  w = 1.0;
% w = 1.1;

% all obs in one pot
lat = [];
lon = [];
zen = [];
sol = [];
tai = [];
asc = logical([]);

% loop on days
for doy = dlist
  tmp = datestr(datenum(year,1,1) + doy - 1, 30);
  geofile = fullfile(ghome, ystr, ['allgeo', tmp(1:8), '.mat']);
  d1 = load(geofile);
  tlat = d1.allgeo.Latitude(iFOV, iFOR, :);
  tlon = d1.allgeo.Longitude(iFOV, iFOR, :);
% tzen = d1.allgeo.SatelliteZenithAngle(:, iFOR, :);
  tsol = d1.allgeo.SolarZenithAngle(:, iFOR, :);
  ttai = iet2tai(d1.allgeo.FORTime(iFOR, :));
  tasc = d1.allgeo.Asc_Desc_Flag;

  tlat = tlat(:);
  tlon = tlon(:);
% tzen = tzen(:);
  tsol = tsol(:);
  ttai = ones(nFOV,1) * ttai(:)';
  ttai = ttai(:);
  tasc = ones(nFOV*nFOR,1) * tasc(:)';
  tasc = tasc(:) == 1;

  lat = [lat; tlat];
  lon = [lon; tlon];
% zen = [zen; tzen];
  sol = [sol; tsol];
  tai = [tai; ttai];
  asc = [asc; tasc];
end

% get good obs subset
iOK = -90 <= lat & lat <= 90 & -180 <= lon & lon <= 180 & ...
      ~isnan(lat) & ~isnan(lon);
lat = lat(iOK);
lon = lon(iOK);
% zen = zen(iOK);
  sol = sol(iOK);
tai = tai(iOK);
asc = asc(iOK);

nobs = numel(lat);
fprintf(1, '%d initial good obs\n', nobs)

% % get latitude subset as rand < abs(cos(lat))
lat_rad = deg2rad(lat);
  ix = rand(nobs, 1) < abs(cos(lat_rad).^w);
% ix = 1 : numel(lat);
slat = lat(ix);
slon = lon(ix);
stai = tai(ix);
sasc = asc(ix);
% szen = zen(ix);
  ssol = sol(ix);
nsub = numel(slat);
fprintf(1, '%d obs after subset\n', nsub)

% asc/desc subset
% slat = slat(~sasc);
% slon = slon(~sasc);
% stai = stai(~sasc);

save cris_obs_xxxx year dlist iFOR iFOV nobs nsub slat slon stai ssol

% save cris_obs_xxxx year dlist iFOR iFOV nobs nsub slat slon stai
% save cris_subpt year dlist iFOR iFOV nobs lat lon tai

return

%---------------------------
% plot equal area grid bins
%---------------------------

nLat = 24;  dLon = 4;
[latB, lonB, gtot] = equal_area_bins(nLat, dLon, slat, slon);

gmean = mean(gtot(:));
grel = (gtot - gmean) / gmean;

tstr = 'CrIS equal area (count - mean) / mean';
equal_area_map(1, latB, lonB, grel, tstr);

%-------------------------
% plot raw latitude bins
%-------------------------
% number of latitude bands is 2 x N
% N1 = 40; N2 = 80; N3 = 120; N4 = 160;
  N1 = 10; N2 = 20; N3 = 30; N4 = 40;
vb1 = equal_area_spherical_bands(N1);
vb2 = equal_area_spherical_bands(N2);
vb3 = equal_area_spherical_bands(N3);
vb4 = equal_area_spherical_bands(N4);

figure(2); clf
  set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
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
figure(3); clf
  set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
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

return

%--------------------------
% plot raw longitude bins
%--------------------------
Lb5  = -180 :  5 : 180;
Lb10 = -180 : 10 : 180;
Lb20 = -180 : 20 : 180;

figure(4); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
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
Lb5  = -180 :  5 : 180;
Lb10 = -180 : 10 : 180;
Lb20 = -180 : 20 : 180;

figure(5); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
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
