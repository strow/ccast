%
% nlc_fit - polynomial fit for nonlinearity correction
%
% fit for forward and inverse gain functions, plot the results.
% derived from testESfit2, uses data from match_a5.m
%

addpath utils
load match_a5_old
band = upper(input('band > ', 's'));

% band specific parameters
switch(band)
  case 'LW',
    radmean = radmeanLW; ESdiff = ESdiffLW; 
    r1 = 0; r2 = 120; r3 = 200;
    v1 = 0; v2 = 0.4; v3 = 0.8;
    iLin = 5;
  case 'MW', 
    radmean = radmeanMW; ESdiff = ESdiffMW;
    r1 = 0; r2 = 18; r3 = 30;
    v1 = 0; v2 = 0.12; v3 = 0.2;
    iLin = 9;
end

% clean up data
[m, n] = size(radmean); 
j = 0;
for i = 1 : n
  if find(radmean(:, i) < 0)
    continue
  end
  j = j + 1;
  radmean(:, j) = radmean(:, i);
  ESdiff(:, j)  = ESdiff(:, i);
  for_tab(j) = for_tab(i);
end

% for fi = 1 : 9;
%   plot(radmean(fi, :), abs(ESdiff(fi, :)), '.')
% % plot(abs(ESdiff(fi, :)), radmean(fi, :), '.')
%   pause
% end

%-----------------
% polynomial fits
%-----------------

% polynomial degree
pd1 = 1;  % correction target
pd2 = 2;  % obs and inverse obs

% initialize arrays
[m, nobs] = size(radmean);
d1 = find(mod(for_tab(:), 2) == 1);
d2 = find(mod(for_tab(:), 2) == 0);
rad1 = radmean(:, d1);       rad2 = radmean(:, d2);
ES1 = abs(ESdiff(:, d1));    ES2 = abs(ESdiff(:, d2));
L1 = zeros(pd1+1, 9);        L2 = zeros(pd1+1, 9);
P1 = zeros(pd2+1, 9);        P2 = zeros(pd2+1, 9);
Q1 = zeros(pd2+1, 9);        Q2 = zeros(pd2+1, 9);
resP1 = zeros(9, 1);         resP2 = zeros(9, 1);
resQ1 = zeros(9, 1);         resQ2 = zeros(9, 1);
LQ1 = zeros(9, 1);           LQ2 = zeros(9, 1);

% loop on FOVs 
for fi = 1 : 9

  % linear gain fnx fits
  L1(:, fi) = polyfit(rad1(fi,:)', ES1(fi, :)', pd1);
  L2(:, fi) = polyfit(rad2(fi,:)', ES2(fi, :)', pd1);

  % polynomial gain fnx fits
  P1(:, fi) = polyfit(rad1(fi,:)', ES1(fi, :)', pd2);
  P2(:, fi) = polyfit(rad2(fi,:)', ES2(fi, :)', pd2);
  resP1(fi) = rms(polyval(P1(:,fi),rad1(fi,:)')-ES1(fi,:)') ./ rms(ES1(fi,:)');
  resP2(fi) = rms(polyval(P2(:,fi),rad2(fi,:)')-ES2(fi,:)') ./ rms(ES2(fi,:)');

  % inverse poly gain fnx fits
  Q1(:, fi) = polyfit(ES1(fi,:)', rad1(fi, :)', pd2);
  Q2(:, fi) = polyfit(ES2(fi,:)', rad2(fi, :)', pd2);
  resQ1(fi) = rms(polyval(Q1(:,fi),ES1(fi,:)')-rad1(fi,:)') ./ rms(rad1(fi,:)');
  resQ2(fi) = rms(polyval(Q2(:,fi),ES2(fi,:)')-rad2(fi,:)') ./ rms(rad2(fi,:)');
end

for fi = 1 : 9
  % correction bias offsets
  LQ1(fi) = polyval(L1(:,iLin), polyval(Q1(:,fi), 0));
  LQ2(fi) = polyval(L2(:,iLin), polyval(Q2(:,fi), 0));
end

% show residuals
[resP1 resP2 resQ1 resQ2]

save(['gainfnx', band], ...
     'L1', 'L2', 'Q1', 'Q2', 'LQ1', 'LQ2', 'iLin', 'pd1', 'pd2')

%---------------
% summary stats
%---------------

% fixed grids for fits and corrections
dr = (r2 - r1) / 200;  dv = (v2 - v1) / 200;
xr = (r1 : dr : r2)';  xv = (v1 : dv : v2)';

nr = length(xr);
yL1 = zeros(nr, 9); yL2 = zeros(nr, 9);  % rad to volts
yP1 = zeros(nr, 9); yP2 = zeros(nr, 9);  % rad to volts
yQ1 = zeros(nr, 9); yQ2 = zeros(nr, 9);  % volts to rad
yc1 = zeros(nr, 9); yc2 = zeros(nr, 9);  % volts to volts
yd1 = zeros(nr, 9); yd2 = zeros(nr, 9);  % rad to volts

% apply fits and corrections to fixed grids
for fi = 1 : 9
  yL1(:, fi) = polyval(L1(:, fi), xr);
  yL2(:, fi) = polyval(L2(:, fi), xr);

  yP1(:, fi) = polyval(P1(:, fi), xr);
  yP2(:, fi) = polyval(P2(:, fi), xr);

  yQ1(:, fi) = polyval(Q1(:, fi), xv);
  yQ2(:, fi) = polyval(Q2(:, fi), xv);

  yc1(:, fi) = polyval(L1(:,iLin), polyval(Q1(:,fi), xv)) - LQ1(fi);
  wc2(:, fi) = polyval(L2(:,iLin), polyval(Q2(:,fi), xv)) - LQ2(fi);

  yd1(:, fi) = ...
     polyval(L1(:,iLin), polyval(Q1(:,fi), polyval(P1(:,fi), xr))) - LQ1(fi);
  yd1(:, fi) = ...
     polyval(L2(:,iLin), polyval(Q2(:,fi), polyval(P2(:,fi), xr))) - LQ2(fi);
end

% forward and inverse polynomial fits, P and Q
figure(1); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
subplot(2,1,1)
plot(xr, yP1, 'linewidth', 2)
axis([r1, r2, v1, v2])
title(sprintf('%s gain functions', band))
legend(fovnames, 'location', 'eastoutside')
xlabel('radiance')
ylabel('volts')
grid on; zoom on

subplot(2,1,2)
plot(xv, yQ1, 'linewidth', 2)
axis([v1, v2, r1, r3])
title(sprintf('%s inverse gain functions', band))
legend(fovnames, 'location', 'eastoutside')
xlabel('volts')
ylabel('radiance')
grid on; zoom on

% actual correction function, L * Q, volts to volts 
figure(2); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(xv, yc1, 'linewidth', 2)
% axis([v1, v2, v1, v3])
title(sprintf('%s correction functions', band))
legend(fovnames, 'location', 'northwest')
xlabel('volts')
ylabel('volts')
grid on; zoom on

% target function L and applied corrections L * Q * P
figure(3); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
subplot(2,1,1)
plot(xr, yL1, 'linewidth', 2)
axis([r1, r2, v1, v2])
title(sprintf('%s target functions', band))
legend(fovnames, 'location', 'eastoutside')
xlabel('radiance')
ylabel('volts')
grid on; zoom on

subplot(2,1,2)
plot(xr, yd1, 'linewidth', 2)
axis([r1, r2, v1, v2])
title(sprintf('%s corrected functions', band))
legend(fovnames, 'location', 'eastoutside')
xlabel('radiance')
ylabel('volts')
grid on; zoom on

