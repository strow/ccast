%
% testESfit1  - plots and fit for ES vs rad matchups
%
% this version does separate polynomial fits to the complex
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
    radmean = radmeanLW; ESmean = ESmeanLW; 
    ax = [10, 120, -0.3, 0.2];
%   radmean = radmeanLW; ESmean = ESdiffLW; 
%   ax = [0, 120, -0.4, 0.4];
  case 'MW', 
    radmean = radmeanMW; ESmean = ESmeanMW;
    ax = [0,  18, -0.08, 0.08];
%   radmean = radmeanMW; ESmean = ESdiffMW;
%   ax = [0,  18, -0.12, 0.12];
end

% initialize arrays
[m, nobs] = size(radmean);
d1 = find(mod(for_tab(:), 2) == 1);
d2 = find(mod(for_tab(:), 2) == 0);

n1 = length(d1);               n2 = length(d2);
rad1 = radmean(:, d1);         rad2 = radmean(:, d2);
ES1re = real(ESmean(:, d1));   ES1im = imag(ESmean(:, d1));
ES2re = real(ESmean(:, d2));   ES2im = imag(ESmean(:, d2));
P1re = zeros(pd+1, 9);         P1im = zeros(pd+1, 9);
P2re = zeros(pd+1, 9);         P2im = zeros(pd+1, 9);
rms1re = zeros(9, 1);          rms1im = zeros(9, 1);
rms2re = zeros(9, 1);          rms2im = zeros(9, 1);

% loop on FOVs, do polynomial fits
for fi = 1 : 9
  P1re(:, fi) = polyfit(rad1(fi,:)', ES1re(fi, :)', pd);
  P1im(:, fi) = polyfit(rad1(fi,:)', ES1im(fi, :)', pd);
  P2re(:, fi) = polyfit(rad2(fi,:)', ES2re(fi, :)', pd);
  P2im(:, fi) = polyfit(rad2(fi,:)', ES2im(fi, :)', pd);

  rms1re(fi) = rms(polyval(P1re(:, fi), rad1(fi,:)') - ES1re(fi,:)');
  rms1im(fi) = rms(polyval(P1im(:, fi), rad1(fi,:)') - ES1im(fi,:)');
  rms2re(fi) = rms(polyval(P2re(:, fi), rad2(fi,:)') - ES2re(fi,:)');
  rms2im(fi) = rms(polyval(P2im(:, fi), rad2(fi,:)') - ES2im(fi,:)');
end

% dump rms residuals
[rms1re, rms1im, rms2re, rms2im]

% apply fits to a fixed grid
r1 = ax(1); r2 = ax(2);
dr = (r2 - r1) / 400;
xfit = r1 : dr : r2;
nr = length(xfit);
y1re = zeros(nr, 9);  y1im = zeros(nr, 9);
y2re = zeros(nr, 9);  y2im = zeros(nr, 9);
z1 = zeros(nr, 9);    z2 = zeros(nr, 9);

for fi = 1 : 9
  y1re(:, fi) = polyval(P1re(:, fi), xfit');
  y1im(:, fi) = polyval(P1im(:, fi), xfit');
  y2re(:, fi) = polyval(P2re(:, fi), xfit');
  y2im(:, fi) = polyval(P2im(:, fi), xfit');
  z1(:, fi) = sqrt(y1re(:, fi).^2 + y1im(:, fi).^2);
  z2(:, fi) = sqrt(y2re(:, fi).^2 + y2im(:, fi).^2);
end

%-------------------------------------
% complex components for selected FOV
%-------------------------------------
figure(1); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
plot(rad1(iFOV,:), ES1re(iFOV,:), 'o', ...
     rad1(iFOV,:), ES1im(iFOV,:), 'o', ...
     rad2(iFOV,:), ES2re(iFOV,:), '+', ...
     rad2(iFOV,:), ES2im(iFOV,:), '+', ...
     xfit, y1re(:, iFOV), 'k', xfit, y1im(:, iFOV), 'k', ...
     xfit, y2re(:, iFOV), 'k', xfit, y2im(:, iFOV), 'k')

axis(ax)
title(sprintf('%s FOV %d complex components', band, iFOV))
legend('d1 real', 'd1 imag', 'd2 real', 'd2 imag', 'location', 'northwest')
xlabel('radiance, mW sr-1 m-2')
ylabel('volts')
grid on;
% saveas(gcf, sprintf('%s_components', band), 'png')

%----------------------------------
% complex modulus for selected FOV
%----------------------------------
figure(2); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(2,1,1)
plot(rad1(iFOV,:), abs(ESmean(iFOV, d1)), '.', xfit, z1(:, iFOV));
axis([ax(1), ax(2), 0, max(abs(ax(3)), abs(ax(4)))])
title(sprintf('%s FOV %d dir 1 complex modulus', band, iFOV))
ylabel('volts')
grid on

subplot(2,1,2)
plot(rad2(iFOV,:), abs(ESmean(iFOV, d2)), '.', xfit, z2(:, iFOV));
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
plot(xfit, z1(:, 1), xfit, z1(:, 2), xfit, z1(:, 3), ...
     xfit, z1(:, 4), xfit, z1(:, 5), xfit, z1(:, 6), ...
     xfit, z1(:, 7), xfit, z1(:, 8), xfit, z1(:, 9), 'linewidth', 2)

axis([ax(1), ax(2), 0, max(abs(ax(3)), abs(ax(4)))])
title(sprintf('%s fitted complex modulus', band))
legend(fovnames, 'location', 'northwest')
xlabel('radiance, mW sr-1 m-2')
ylabel('volts')
grid on;
% saveas(gcf, sprintf('%s_mod_fit', band), 'png')

%---------------------------------
% basic complex modulus, all FOVs
%---------------------------------
figure(4); clf
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

