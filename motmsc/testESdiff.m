%
% testESdiff  - plots and fit for ES-SP vs rad matchup
%

addpath utils

load match_a5

band = upper(input('band > ', 's'));
iFOV = input('FOV > ');

% band specific params
switch(band)
  case 'LW',
    radmean = radmeanLW; ESmean = ESdiffLW; 
    ax = [0, 120, -0.4, 0.4];
  case 'MW', 
    radmean = radmeanMW; ESmean = ESdiffMW;
    ax = [0,  18, -0.12, 0.12];
end

% option to just use one FOV
% radmean = ones(9, 1) * radmean(9, :);

% initialize arrays
[m, nobs] = size(radmean);
d1 = find(mod(for_tab(:), 2) == 1);
d2 = find(mod(for_tab(:), 2) == 0);

n1 = length(d1);               n2 = length(d2);
rad1 = radmean(:, d1);         rad2 = radmean(:, d2);
ES1re = real(ESmean(:, d1));   ES1im = imag(ESmean(:, d1));
ES2re = real(ESmean(:, d2));   ES2im = imag(ESmean(:, d2));
X1re = zeros(2, 9);            X1im = zeros(2, 9);
X2re = zeros(2, 9);            X2im = zeros(2, 9);
rms1re = zeros(9, 1);          rms1im = zeros(9, 1);
rms2re = zeros(9, 1);          rms2im = zeros(9, 1);

% loop on FOVs, do linear fits
for fi = 1 : 9
  X1re(:, fi) = [rad1(fi,:)', ones(n1, 1)] \ ES1re(fi, :)';
  X1im(:, fi) = [rad1(fi,:)', ones(n1, 1)] \ ES1im(fi, :)';
  X2re(:, fi) = [rad2(fi,:)', ones(n2, 1)] \ ES2re(fi, :)';
  X2im(:, fi) = [rad2(fi,:)', ones(n2, 1)] \ ES2im(fi, :)';

  rms1re(fi) = rms((X1re(1,fi)*rad1(fi,:)' + X1re(2,fi)) - ES1re(fi,:)');
  rms1im(fi) = rms((X1im(1,fi)*rad1(fi,:)' + X1im(2,fi)) - ES1re(fi,:)');
  rms2re(fi) = rms((X2re(1,fi)*rad2(fi,:)' + X2re(2,fi)) - ES1re(fi,:)');
  rms2im(fi) = rms((X2im(1,fi)*rad2(fi,:)' + X2im(2,fi)) - ES1re(fi,:)');
end

% dump rms residuals
[rms1re, rms1im, rms2re, rms2im]

% apply linear fits to a fixed grid
r1 = ax(1); r2 = ax(2);
dr = (r2 - r1) / 400;
xfit = r1 : dr : r2;
nr = length(xfit);
y1re = zeros(nr, 9);  y1im = zeros(nr, 9);
y2re = zeros(nr, 9);  y2im = zeros(nr, 9);
z1 = zeros(nr, 9);    z2 = zeros(nr, 9);

for fi = 1 : 9
  y1re(:, fi) =  X1re(1,fi)*xfit' + X1re(2,fi);
  y1im(:, fi) =  X1im(1,fi)*xfit' + X1im(2,fi);
  y2re(:, fi) =  X2re(1,fi)*xfit' + X2re(2,fi);
  y2im(:, fi) =  X2im(1,fi)*xfit' + X2im(2,fi);
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
legend('d1 real', 'd1 imag', 'd2 real', 'd2 imag', 'location', 'southeast')
xlabel('radiance, mW sr-1 m-2')
ylabel('volts')
grid on;
% saveas(gcf, sprintf('%s_FOV_%d_comp', band, iFOV), 'png')

%----------------------------------
% complex modulus for selected FOV
%----------------------------------
figure(2); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(2,1,1)
plot(rad1(iFOV,:), abs(ESmean(iFOV, d1)), 'o', xfit, z1(:, iFOV));
axis([ax(1), ax(2), 0, max(abs(ax(3)), abs(ax(4)))])
title(sprintf('%s FOV %d dir 1 complex modulus', band, iFOV))
ylabel('volts')
grid on

subplot(2,1,2)
plot(rad2(iFOV,:), abs(ESmean(iFOV, d2)), 'o', xfit, z2(:, iFOV));
axis([ax(1), ax(2), 0, max(abs(ax(3)), abs(ax(4)))])
title(sprintf('%s FOV %d dir 2 complex modulus', band, iFOV))
xlabel('radiance, mW sr-1 m-2')
ylabel('volts')
grid on;
% saveas(gcf, sprintf('%s_FOV_%d_mod', band, iFOV), 'png')

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
legend(fovnames, 'location', 'southeast')
xlabel('radiance, mW sr-1 m-2')
ylabel('volts')
grid on;
% saveas(gcf, sprintf('%s_ES-SP_mod_fit', band), 'png')

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
legend(fovnames, 'location', 'southeast')
xlabel('radiance, mW sr-1 m-2')
ylabel('volts')
grid on;
% saveas(gcf, sprintf('%s_ES-SP_mod_obs', band), 'png')

