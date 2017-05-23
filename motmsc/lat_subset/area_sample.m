%
% random selection for constant obs as a function of area
%

% get geo data for a full day
load /asl/data/cris/ccast/daily/2017/allgeo20170113.mat

% allgeo usually has 1080 scans
[~, nscan] = size(allgeo.FORTime);

% use only valid latitude data
s0 = allgeo.Latitude(:);
s0 = s0(s0 > -100);
fprintf(1, '%d initial good obs\n', numel(s0))

% choose number of latitude bands (2 x N)
N = 10;
vb = equal_area_spherical_bands(N);
nb = length(vb) - 1;
f1 = zeros(nb, 1);

% histogram of obs counts by latitude band
for i = 1 : nb;
  f1(i) = sum(vb(i) <= s0  &  s0 < vb(i+1));
end
sum(f1)

figure(1); clf
x1 = (vb(1:nb) + vb(2:nb+1)) / 2;
subplot(2,1,1)
bar(x1, f1)
title('CrIS obs by latitude band')
xlabel('latitude')
ylabel('obs counts')
grid on

% choose a subset as rand < abs(cos(lat))
lat_rad = deg2rad(allgeo.Latitude);
ix = rand(9,30,nscan) < abs(cos(lat_rad));
fprintf(1, '%d obs after subset\n', sum(ix(:)))

% get subset counts by latitude
s1 = allgeo.Latitude(ix);
s1 = s1(:);
s1 = s1(s1 > -100);

% histogram of obs subset counts by latitude band
fx = zeros(nb, 1);
for i = 1 : nb;
  fx(i) = sum(vb(i) <= s1  &  s1 < vb(i+1));
end

subplot(2,1,2)
bar(x1, fx)
title('CrIS with cos(lat) band subsetting')
xlabel('latitude')
ylabel('obs counts')
grid on

