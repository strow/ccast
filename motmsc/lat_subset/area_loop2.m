%
% area_loop2 -- compare matlab histogram and explicit binning
%

% total number of latitude bands is 2 x N
N = 40;

% allgeo year prefix
ghome = '/asl/data/cris/ccast/daily';

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

% calculate latitude bands
vb = equal_area_spherical_bands(N);
nb = length(vb) - 1;

% latitude band midpoints
x1 = (vb(1:nb) + vb(2:nb+1)) / 2;

% histogram of obs counts by latitude band
h1 = zeros(nb, 1);
for i = 1 : nb;
  h1(i) = sum(vb(i) <= s1  &  s1 < vb(i+1));
end
% sum(h1)

% choose a subset as rand < abs(cos(lat))
lat_rad = deg2rad(Latitude);
% ix = rand(9,nFOR,nscan) < abs(cos(lat_rad));
  ix = rand(9,nFOR,nscan) < abs(cos(lat_rad).^1.1);
fprintf(1, '%d obs after subset\n', sum(ix(:)))

% get subset counts by latitude
s2 = Latitude(ix);
s2 = s2(:);
s2 = s2(s2 > -100);

% histogram of s2 obs subset counts by latitude band
h2 = zeros(nb, 1);
for i = 1 : nb;
  h2(i) = sum(vb(i) <= s2  &  s2 < vb(i+1));
end

figure(1); clf
subplot(2,1,1)
bar(x1, h1)
title('CrIS obs by latitude band')
xlabel('latitude')
ylabel('obs counts')
grid on

subplot(2,1,2)
bar(x1, h2)
title('CrIS with cos(lat)^w band subsetting')
xlabel('latitude')
ylabel('obs counts')
grid on

figure(2); clf
subplot(2,1,1)
histogram(s1, vb)
title('CrIS obs by latitude band')
xlabel('latitude')
ylabel('obs counts')
grid on

subplot(2,1,2)
histogram(s2, vb)
title('CrIS with cos(lat)^w band subsetting')
xlabel('latitude')
ylabel('obs counts')
grid on

