%
% area_loop3 - raw and subset obs by lat bin for 4 values of N
%

% allgeo year prefix
ghome = '/asl/data/cris/ccast/daily';

% number of latitude bands is 2 x N
% N1 = 40; N2 = 80; N3 = 120; N4 = 160;
  N1 = 10; N2 = 20; N3 = 30; N4 = 40
vb1 = equal_area_spherical_bands(N1);
vb2 = equal_area_spherical_bands(N2);
vb3 = equal_area_spherical_bands(N3);
vb4 = equal_area_spherical_bands(N4);

% specify year
year = 2016;
ystr = sprintf('%d', year);

% specify days of the year
dlist = 1 : 71 : 365;

% specify FORs
iFOR = 15:16;
nFOR = length(iFOR);

% loop on days
Latitude = [];
for doy = dlist
  tmp = datestr(datenum(year,1,1) + doy - 1, 30);
  geofile = fullfile(ghome, ystr, ['allgeo', tmp(1:8), '.mat']);
  d1 = load(geofile);
  Latitude = cat(3, Latitude, d1.allgeo.Latitude);
end

% get the total scan count
[~, ~, nscan] = size(Latitude);

% subset by FOR
Latitude = Latitude(:, 15:16, :);

% use only valid latitude data
s1 = Latitude(:);
s1 = s1(s1 > -100);
fprintf(1, '%d initial good obs\n', numel(s1))

figure(1); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(4,1,1)
histogram(s1, vb1)
title(sprintf('CrIS obs by latitude band, N = %d', N1))
ylabel('obs count')
grid on

subplot(4,1,2)
histogram(s1, vb2)
title(sprintf('CrIS obs by latitude band, N = %d', N2))
ylabel('obs count')
grid on

subplot(4,1,3)
histogram(s1, vb3)
title(sprintf('CrIS obs by latitude band, N = %d', N3))
ylabel('obs count')
grid on

subplot(4,1,4)
histogram(s1, vb4)
title(sprintf('CrIS obs by latitude band, N = %d', N4))
xlabel('latitude')
ylabel('obs count')
grid on

% choose a subset as rand < abs(cos(lat))
lat_rad = deg2rad(Latitude);
% ix = rand(9,nFOR,nscan) < abs(cos(lat_rad));
  ix = rand(9,nFOR,nscan) < abs(cos(lat_rad).^1.1);
fprintf(1, '%d obs after subset\n', sum(ix(:)))

% get subset counts by latitude
s2 = Latitude(ix);
s2 = s2(:);
s2 = s2(s2 > -100);

figure(2); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(4,1,1)
histogram(s2, vb1)
title(sprintf('rand < cos(lat)^w by latitude band, N = %d', N1))
ylabel('obs count')
grid on

subplot(4,1,2)
histogram(s2, vb2)
title(sprintf('rand < cos(lat)^w by latitude band, N = %d', N2))
ylabel('obs count')
grid on

subplot(4,1,3)
histogram(s2, vb3)
title(sprintf('rand < cos(lat)^w by latitude band, N = %d', N3))
ylabel('obs count')
grid on

subplot(4,1,4)
histogram(s2, vb4)
title(sprintf('rand < cos(lat)^w by latitude band, N = %d', N4))
xlabel('latitude')
ylabel('obs count')
grid on
