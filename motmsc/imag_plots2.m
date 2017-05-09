%
% imag_plot2 -- plot out of range complex residuals, 
%

function nout = imag_plot2(v, btmp, ctmp, LB, UB, band, di, fi, i1, j1)

switch(band)
  case 'LW', v1 =  650; v2 = 1100; r1 = -5; r2 = 5;
  case 'MW', v1 = 1200; v2 = 1750; r1 = -0.8; r2 = 0.8;
  case 'SW', v1 = 2150; v2 = 2550; r1 = -0.15; r2 = 0.15;
end

% find outliers by FOV
j = 0;
ftab = struct;
for i = 1 : 9
  ix = find(ctmp(:,i) < LB(:,i) | UB(:,i) < ctmp(:,i));
  if ~isempty(ix)
    j = j + 1;
    ftab(j).fov = i;
    ftab(j).out = ix;
  end
end
if j == 0, error('no outliers found'), end

% status message
fprintf(1, '\n%s day %d file %d scan %d FOR %d nfov %d', ...
        band, di, fi, j1, i1, j);

% for now just plot first FOV found
ifov = ftab(1).fov;
iout = ftab(1).out;

figure(1);
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
subplot(2,1,1)
plot(v, btmp)
ax = axis; ax(1) = v1; ax(2) = v2; axis(ax)
title('associated spectra')
legend(fovnames, 'location', 'southwest')
ylabel('Tb, K')
grid on; zoom on

subplot(2,1,2)
plot(v, ctmp(:,ifov), v, UB(:,ifov), v, LB(:,ifov), ...
     v(iout), ctmp(iout, ifov), 'ok', 'linewidth', 2)
axis([v1, v2, r1, r2])
title(sprintf('FOV %d complex residual', ifov))
legend('residual', 'upper bound', 'lower bound', 'outlier', ...
       'location', 'southwest')
ylabel('radiance')
xlabel('wavenumber')
grid on; zoom on

waitforbuttonpress

