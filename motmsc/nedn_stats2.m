%
% nedn_stats2 - ICT noise correlation matrix, SVD, and plots
%
% calculates the ICT correlation matrix and (optionally) does an SVD
% correlation check using data nedn_cat.mat produced by nedn_stats1
%

addpath ../source

load nedn_cat

iFOV = 1;
ictLW = squeeze(ictLW(:, iFOV, :));
ictMW = squeeze(ictMW(:, iFOV, :));
ictSW = squeeze(ictSW(:, iFOV, :));

% correlation matrix
k = 15;
mavgLW = movavg1(ictLW, k);
mavgMW = movavg1(ictMW, k);
mavgSW = movavg1(ictSW, k);

dLW = ictLW - mavgLW;
dMW = ictMW - mavgMW;
dSW = ictSW - mavgSW;

cLW = corrcoef(dLW');
cMW = corrcoef(dMW');
cSW = corrcoef(dSW');

figure(1); clf
mesh(vLW, vLW, cLW)
ax = axis; ax(5) = 0; axis(ax)
title('LW ICT noise correlation')
% saveas(gcf, 'LW_noise_corr', 'png')

figure(2); clf
mesh(vMW, vMW, cMW)
ax = axis; ax(5) = 0; axis(ax)
title('MW ICT noise correlation')
% saveas(gcf, 'MW_noise_corr', 'png')

figure(3); clf
subplot(3,1,1)
ix = floor(length(vLW)/2);
plot(vLW, cLW(:, ix))
ax = axis; ax(3) = 0; ax(4) = 1; axis(ax)
title('LW noise correlation sample col')
grid on; zoom on

subplot(3,1,2)
ix = floor(length(vMW)/2);
plot(vMW, cMW(:, ix))
title('MW noise correlation sample col')
grid on; zoom on

subplot(3,1,3)
ix = floor(length(vSW)/2);
plot(vSW, cSW(:, ix))
title('SW noise correlation sample col')
xlabel('wavenumber')
grid on; zoom on
% saveas(gcf, 'noise_corr_cols', 'png')

return

% singular values
[uLW, sLW, vLW] = svd(ictLW, 0);
[uMW, sMW, vMW] = svd(ictMW, 0);
[uSW, sSW, vSW] = svd(ictSW, 0);

figure(4)
subplot(3,1,1)
plot(diag(sLW))
ax = axis; ax(3) = 2; ax(4) = 12; axis(ax)
title('LW ICT singular values')
grid on; zoom on

subplot(3,1,2)
plot(diag(sMW))
ax = axis; ax(3) = 1; ax(4) = 4; axis(ax)
title('MW ICT singular values')
grid on; zoom on

subplot(3,1,3)
plot(diag(sSW))
ax = axis; ax(3) = 0; ax(4) = 0.5; axis(ax)
title('SW ICT singular values')
grid on; zoom on
% saveas(gcf, 'ICT_sing_vals', 'png')

