%
% testESfit2  - plots and fit for ES vs rad matchups
%
% this version fits to complex modulus rather than components,
% components of ES or ES - SP 
%
% uses matchup data from match_a5, default is ccast runs h3a2new for
% calibrated radiances and uncal_a5 for the uncalibrated ES, ICT and
% space looks
%

addpath utils

load match_a5

band = upper(input('band > ', 's'));
iFOV = input('FOV > ');

% polynomial degree
pd = input('fit degree > ');

% band specific params
switch(band)
  case 'LW',
%   radmean = radmeanLW; ESmean = ESmeanLW; 
%   ax = [10, 120, -0.3, 0.2];
    radmean = radmeanLW; ESmean = ESdiffLW; 
    ax = [0, 120, -0.4, 0.4];
  case 'MW', 
%   radmean = radmeanMW; ESmean = ESmeanMW;
%   ax = [0,  18, -0.08, 0.08];
    radmean = radmeanMW; ESmean = ESdiffMW;
    ax = [0,  18, -0.12, 0.12];
end

% initialize arrays
[m, nobs] = size(radmean);
d1 = find(mod(for_tab(:), 2) == 1);
d2 = find(mod(for_tab(:), 2) == 0);
rad1 = radmean(:, d1);
rad2 = radmean(:, d2);
ES1 = abs(ESmean(:, d1));
ES2 = abs(ESmean(:, d2));
P1 = zeros(pd+1, 9);
P2  = zeros(pd+1, 9);
rms1 = zeros(9, 1);
rms2 = zeros(9, 1);

% loop on FOVs, do polynomial fits
for fi = 1 : 9
  P1(:, fi) = polyfit(rad1(fi,:)', ES1(fi, :)', pd);
  P2(:, fi) = polyfit(rad2(fi,:)', ES2(fi, :)', pd);
  rms1(fi) = rms(polyval(P1(:, fi), rad1(fi,:)') - ES1(fi,:)');
  rms2(fi) = rms(polyval(P2(:, fi), rad2(fi,:)') - ES2(fi,:)');
end

% dump rms residuals
[rms1, rms2]

% apply fits to a fixed grid
r1 = ax(1); r2 = ax(2);
dr = (r2 - r1) / 400;
xfit = r1 : dr : r2;
nr = length(xfit);
y1 = zeros(nr, 9);
y2 = zeros(nr, 9);

for fi = 1 : 9
  y1(:, fi) = polyval(P1(:, fi), xfit');
  y2(:, fi) = polyval(P2(:, fi), xfit');
end

%---------------------------------
% basic complex modulus, all FOVs
%---------------------------------
figure(1); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
ix = d2;
plot(radmean(1, ix), abs(ESmean(1, ix)), 'o', ...
     radmean(2, ix), abs(ESmean(2, ix)), 'o', ...
     radmean(3, ix), abs(ESmean(3, ix)), 'o', ...
     radmean(4, ix), abs(ESmean(4, ix)), 'o', ...
     radmean(5, ix), abs(ESmean(5, ix)), 'o', ...
     radmean(6, ix), abs(ESmean(6, ix)), 'o', ...
     radmean(7, ix), abs(ESmean(7, ix)), 'o', ...
     radmean(8, ix), abs(ESmean(8, ix)), 'o', ...
     radmean(9, ix), abs(ESmean(9, ix)), 'o')

axis([ax(1), ax(2), 0, max(abs(ax(3)), abs(ax(4)))])
title(sprintf('%s voltage as a function of radiance', band))
legend(fovnames, 'location', 'northwest')
xlabel('radiance, mW sr-1 m-2')
ylabel('volts')
grid on;
% saveas(gcf, sprintf('%s_mod_obs', band), 'png')

%------------------------------------------
% complex modulus and fit for selected FOV
%------------------------------------------
figure(2); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(2,1,1)
plot(rad1(iFOV,:), abs(ESmean(iFOV, d1)), '.', xfit, y1(:, iFOV));
axis([ax(1), ax(2), 0, max(abs(ax(3)), abs(ax(4)))])
title(sprintf('%s FOV %d dir 1 complex modulus', band, iFOV))
ylabel('volts')
grid on

subplot(2,1,2)
plot(rad2(iFOV,:), abs(ESmean(iFOV, d2)), '.', xfit, y2(:, iFOV));
axis([ax(1), ax(2), 0, max(abs(ax(3)), abs(ax(4)))])
title(sprintf('%s FOV %d dir 2 complex modulus', band, iFOV))
xlabel('radiance, mW sr-1 m-2')
ylabel('volts')
grid on;
% saveas(gcf, sprintf('%s_modulus', band), 'png')

%----------------------------------
% fitted complex modulus, all FOVs
%----------------------------------
figure(3)
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(xfit, y1(:, 1), xfit, y1(:, 2), xfit, y1(:, 3), ...
     xfit, y1(:, 4), xfit, y1(:, 5), xfit, y1(:, 6), ...
     xfit, y1(:, 7), xfit, y1(:, 8), xfit, y1(:, 9), 'linewidth', 2)

axis([ax(1), ax(2), 0, max(abs(ax(3)), abs(ax(4)))])
title(sprintf('%s fitted complex modulus', band))
legend(fovnames, 'location', 'northwest')
xlabel('radiance, mW sr-1 m-2')
ylabel('volts')
grid on;
% saveas(gcf, sprintf('%s_mod_fit', band), 'png')


