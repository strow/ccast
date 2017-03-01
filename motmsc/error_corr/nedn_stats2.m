%
% nedn_stats2 - ICT noise correlation matrix, SVD, and plots
%
% uses data nedn_cat.mat from nedn_stats1 to calculate the ICT
% noise correlation matrix and optionally an SVD correlation 
%

addpath ../source

load nedn_cat

% select a FOV
iFOV = 5;
ictLW = squeeze(ictLW(:, iFOV, :));
ictMW = squeeze(ictMW(:, iFOV, :));
ictSW = squeeze(ictSW(:, iFOV, :));
[~, nobs] = size(ictLW);

% 2*k + 1 moving averages
k = 6;
mavgLW = movavg1(ictLW, k);
mavgMW = movavg1(ictMW, k);
mavgSW = movavg1(ictSW, k);

% diff vs moving averages
dLW = ictLW - mavgLW;
dMW = ictMW - mavgMW;
dSW = ictSW - mavgSW;

% frequency correlation
cLW = corrcoef(dLW');
cMW = corrcoef(dMW');
cSW = corrcoef(dSW');

figure(1); clf
imagesc(vLW, vLW, cLW);
set(gca,'YDir','normal')
title('LW ICT noise correlation')
xlabel('wavenumber')
ylabel('wavenumber')
colorbar
% saveas(gcf, 'LW_noise_corr', 'png')

figure(2); clf
imagesc(vMW, vMW, cMW);
set(gca,'YDir','normal')
title('MW ICT noise correlation')
xlabel('wavenumber')
ylabel('wavenumber')
colorbar
% saveas(gcf, 'MW_noise_corr', 'png')

% % time correlation (?)
% tLW = corrcoef(dLW);
% 
% figure(2); clf
% imagesc(0:24, 0:24, tLW);
% set(gca,'YDir','normal')
% xlabel('hour')
% ylabel('hour')
% colorbar

% % nedn is higher over the 1-day set
% nednLW1 = std(ictLW(:, 1:120), 0, 2);
% nednLW2 = std(ictLW, 0, 2);
% plot(vLW, nednLW1, vLW, nednLW2)

% figure(1); clf
% mesh(vLW, vLW, cLW)
% ax = axis; ax(5) = 0; axis(ax)
% title('LW ICT noise correlation')

% figure(2); clf
% mesh(vMW, vMW, cMW)
% ax = axis; ax(5) = 0; axis(ax)
% title('MW ICT noise correlation')

figure(3); clf
subplot(3,1,1)
ix = floor(length(vLW)/2);
plot(vLW, cLW(:, ix))
axis([650, 1100, -0.2, 1.2])
title('LW correlation sample col')
grid on; zoom on

subplot(3,1,2)
ix = floor(length(vMW)/2);
plot(vMW, cMW(:, ix))
axis([1200, 1750, -0.2, 1.2])
title('MW correlation sample col')
grid on; zoom on

subplot(3,1,3)
ix = floor(length(vSW)/2);
plot(vSW, cSW(:, ix))
axis([2150, 2550, -0.2, 1.2])
title('SW correlation sample col')
xlabel('wavenumber')
grid on; zoom on
% saveas(gcf, 'noise_corr_cols', 'png')

% singular values
[uLW, sLW, vLW] = svd(ictLW, 0);
[uMW, sMW, vMW] = svd(ictMW, 0);
[uSW, sSW, vSW] = svd(ictSW, 0);

figure(4); clf
subplot(3,1,1)
semilogy(diag(sLW))
axis([0, 20, 0, 1e5])
title('LW ICT singular values')
grid on; zoom on

subplot(3,1,2)
semilogy(diag(sMW))
axis([0, 20, 0, 1e5])
title('MW ICT singular values')
grid on; zoom on

subplot(3,1,3)
semilogy(diag(sSW))
axis([0, 20, 0, 1e5])
title('SW ICT singular values')
grid on; zoom on
% saveas(gcf, 'ICT_sing_vals', 'png')


