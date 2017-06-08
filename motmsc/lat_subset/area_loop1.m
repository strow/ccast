%
% area_loop1 - raw and two different subset obs by lat bin
%

% number of latitude bands (2 x N)
N = 6;

% allgeo year prefix
ghome = '/asl/data/cris/ccast/daily';

% specify year
year = 2016;
ystr = sprintf('%d', year);

% specify days of the year
dlist = 1 : 71 : 365;

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

% use only valid latitude data
s0 = Latitude(:);
s0 = s0(s0 > -100);
fprintf(1, '%d initial good obs\n', numel(s0))

% calculate latitude bands
vb = equal_area_spherical_bands(N);
nb = length(vb) - 1;
f1 = zeros(nb, 1);

% histogram of obs counts by latitude band
for i = 1 : nb;
  f1(i) = sum(vb(i) <= s0  &  s0 < vb(i+1));
end
% sum(f1)

% latitude band midpoints
x1 = (vb(1:nb) + vb(2:nb+1)) / 2;

% % spline fit to f1, the histogram
% pp = spline(x1, f1);
% 
% % sample x3 and f3 values for plot
% x2 = -90 : 1 : 90;
% f2 = ppval(pp, x2);
% c1 = min(f2);
% c2 = max(f2);
% f3 = 1 - (f2 - c1)/(c2 - c1);
% 
% figure(2); clf
% plot(x2, f3, x2, cos(deg2rad(x2)))
% grid on

figure(1); clf
subplot(2,1,1)
bar(x1, f1)
title('CrIS obs by latitude band')
xlabel('latitude')
ylabel('obs counts')
grid on

% choose a subset as rand < abs(cos(lat))
lat_rad = deg2rad(Latitude);
  ix = rand(9,30,nscan) < abs(cos(lat_rad));
  iy = rand(9,30,nscan) < abs(cos(lat_rad).^1.1);
% ix = rand(9,30,nscan) < (1 - (ppval(pp, Latitude) - c1) / (c2 - c1));
fprintf(1, '%d obs after subset\n', sum(ix(:)))

% get subset counts by latitude
s1 = Latitude(ix);
s1 = s1(:);
s1 = s1(s1 > -100);

% histogram of s1 obs subset counts by latitude band
h1 = zeros(nb, 1);
for i = 1 : nb;
  h1(i) = sum(vb(i) <= s1  &  s1 < vb(i+1));
end

subplot(2,1,2)
bar(x1, h1)
title('CrIS with cos(lat) band subsetting')
xlabel('latitude')
ylabel('obs counts')
grid on

% get subset counts by latitude
s2 = Latitude(iy);
s2 = s2(:);
s2 = s2(s2 > -100);

% histogram of s2 obs subset counts by latitude band
h2 = zeros(nb, 1);
for i = 1 : nb;
  h2(i) = sum(vb(i) <= s2  &  s2 < vb(i+1));
end

figure(2); clf
subplot(2,1,1)
bar(x1, h1)
title('CrIS with cos(lat) band subsetting')
ylabel('obs counts')
grid on

subplot(2,1,2)
bar(x1, h2)
title('CrIS with cos(lat)^w band subsetting')
xlabel('latitude')
ylabel('obs counts')
grid on
