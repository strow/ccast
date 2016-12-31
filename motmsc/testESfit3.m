%
% testESfit3  - get correction from ES - SP vs rad fit
%
% this version fits to complex modulus rather than components
%
% uses matchup data from match_a5, default is ccast runs h3a2new for
% calibrated radiances and uncal_a5 for the uncalibrated ES, ICT and
% space looks
%

addpath utils

load match_a5

band = upper(input('band > ', 's'));

% polynomial degree
% pd = input('fit degree > ');
pd = 3;

% band specific params
switch(band)
  case 'LW',
%   radmean = radmeanLW; ESmean = ESmeanfLW; 
%   ax = [10, 120, -0.3, 0.2];
    radmean = radmeanLW; ESmean = ESdiffLW; 
    ax = [0, 120, -0.4, 0.4];
    iFOV = 5;
  case 'MW', 
%   radmean = radmeanMW; ESmean = ESmeanfMW;
%   ax = [0,  18, -0.08, 0.08];
    radmean = radmeanMW; ESmean = ESdiffMW;
    ax = [0,  18, -0.12, 0.12];
    iFOV = 9;
end

% initialize arrays
[m, nobs] = size(radmean);
d1 = find(mod(for_tab(:), 2) == 1);
d2 = find(mod(for_tab(:), 2) == 0);
rad1 = radmean(:, d1);
rad2 = radmean(:, d2);
ES1 = abs(ESmean(:, d1));
ES2 = abs(ESmean(:, d2));
L1 = zeros(2, 9);
L2 = zeros(2, 9);
P1 = zeros(pd+1, 9);
P2  = zeros(pd+1, 9);
rms1 = zeros(9, 1);
rms2 = zeros(9, 1);

% loop on FOVs, do linear fits
for fi = 1 : 9
  L1(:, fi) = polyfit(rad1(fi,:)', ES1(fi, :)', 1);
  L2(:, fi) = polyfit(rad2(fi,:)', ES2(fi, :)', 1);
% rms1(fi) = rms(polyval(L1(:, fi), rad1(fi,:)') - ES1(fi,:)');
% rms2(fi) = rms(polyval(L2(:, fi), rad2(fi,:)') - ES2(fi,:)');
end

% loop on FOVs, do polynomial fits
for fi = 1 : 9
  P1(:, fi) = polyfit(rad1(fi,:)', ES1(fi, :)', pd);
  P2(:, fi) = polyfit(rad2(fi,:)', ES2(fi, :)', pd);
  rms1(fi) = rms(polyval(P1(:, fi), rad1(fi,:)') - ES1(fi,:)');
  rms2(fi) = rms(polyval(P2(:, fi), rad2(fi,:)') - ES2(fi,:)');
end

% dump rms residuals
% [rms1, rms2]

% apply linear fits to a fixed grid
r1 = ax(1); r2 = ax(2);
dr = (r2 - r1) / 400;
xv = (r1 : dr : r2)';
nr = length(xv);
y1 = zeros(nr, 9); y2 = zeros(nr, 9);
w1 = zeros(nr, 9); w2 = zeros(nr, 9);
z1 = zeros(nr, 9); z2 = zeros(nr, 9);

for fi = 1 : 9
  y1(:, fi) = polyval(P1(:, fi), xv);
  y2(:, fi) = polyval(P2(:, fi), xv);

  w1(:, fi) = polyval(L1(:, iFOV), xv) ./ polyval(P1(:, fi), xv);
  w2(:, fi) = polyval(L2(:, iFOV), xv) ./ polyval(P2(:, fi), xv);

  z1(:, fi) = w2(:, fi) .* polyval(P1(:, fi), xv);
  z2(:, fi) = w2(:, fi) .* polyval(P2(:, fi), xv);
end

% save gainfunLW L1 L2 P1 P2

figure(1); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(xv, z1, xv, z2)

% axis([ax(1), ax(2), 0, max(abs(ax(3)), abs(ax(4)))])
% title(sprintf('%s fitted complex modulus', band))
% legend(fovnames, 'location', 'northwest')
xlabel('radiance, mW sr-1 m-2')
ylabel('volts')
grid on;
% saveas(gcf, sprintf('%s_mod_fit', band), 'png')


