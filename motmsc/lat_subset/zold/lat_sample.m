%
% random selection for constant obs as a function of latitude
%

% get geo data for a full day
load /asl/data/cris/ccast/daily/2017/allgeo20170108.mat

% allgeo usually has 1080 scans
[~, nscan] = size(allgeo.FORTime);

% use only valid latitude data
s0 = allgeo.Latitude(:);
s0 = s0(s0 > -100);
fprintf(1, '%d initial good obs\n', numel(s0))

% histogram of obs counts by latitude
nb = 100;
figure(1); clf
hist(s0, nb);
title('all CrIS obs latitudes, for a full day')
xlabel('latitude')
ylabel('obs counts')
grid on

% use the histogram as a weighting function
[f1, x1] = hist(s0, nb);
f2 = f1 / (1.7 * max(f1));
pp = spline(x1, f2);
x2 = -90 : 0.5 : 90;
figure(2); clf
subplot(2,1,1)
plot(x2, ppval(pp, x2))
title('selection weighting function')
xlabel('latitude')
ylabel('weight')
grid on

% random selection of weighted latitude
ix = rand(9,30,nscan) > ppval(pp, allgeo.Latitude);
fprintf(1, '%d obs after lat subset\n', sum(ix(:)))

% random subset counts by latitude
s1 = allgeo.Latitude(ix);
s1 = s1(:);
s1 = s1(s1 > -100);
subplot(2,1,2)
hist(s1, nb)
title('CrIS with latitude subsetting')
xlabel('latitude')
ylabel('obs counts')
grid on

