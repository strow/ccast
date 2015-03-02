%
% nedn_test4 -- NEdN svd and filter demo plots
%
% uses nedn_tab.mat from nedn_tab1.m
%

% NEdN data
load nedn_tab_LR

% parameters
di = 1;     % sweep direction (1 or 2)
fi = 1;     % specify a FOV (1 to 9)
si = 201;   % scan index for sample plots
kLW = 6;    % number of LW basis vectors
kMW = 5;    % number of MW basis vectors
kSW = 4;    % number of SW basis vectors

neLW1 = squeeze(nLWtab(:, fi, di, :));
[u,s,v] = svd(neLW1, 0);
dLW = diag(s);
uLW = u(:, 1:kLW);
neLW2 = uLW * uLW' * neLW1;

neMW1 = squeeze(nMWtab(:, fi, di, :));
[u,s,v] = svd(neMW1, 0);
dMW = diag(s);
uMW = u(:, 1:kMW);
neMW2 = uMW * uMW' * neMW1;

neSW1 = squeeze(nSWtab(:, fi, di, :));
[u,s,v] = svd(neSW1, 0);
dSW = diag(s);
uSW = u(:, 1:kSW);
neSW2 = uSW * uSW' * neSW1;

% plot singular values
figure(1); clf
ix = 1 : 100;
loglog(ix, dLW(ix), ix, dMW(ix), ix, dSW(ix))
title(sprintf('FOV %d NEdN singular values', fi))
legend('LW', 'MW', 'SW')
xlabel('index')
ylabel('weight')
grid on; zoom on
% saveas(gcf, 'singular_values', 'png') 

% LW left-singular vectors
figure(2); clf
plot(vLW, uLW(:, 1:4))
title(sprintf('FOV %d LW NEdN first 4 left singular vectors', fi))
axis([650, 1100, -0.1, 0.1])
legend('1', '2', '3', '4', 'location', 'southeast')
xlabel('wavenumber')
ylabel('weight')
grid on; zoom on
% saveas(gcf, 'LW_sing_vecs', 'png') 

% MW left-singular vectors
figure(3); clf
plot(vMW, uMW(:, 1:4))
axis([1200, 1760, -0.2, 0.2])
title(sprintf('FOV %d MW NEdN first 4 left singular vectors', fi))
legend('1', '2', '3', '4', 'location', 'southwest')
xlabel('wavenumber')
ylabel('weight')
grid on; zoom on
% saveas(gcf, 'MW_sing_vecs', 'png') 

% SW left-singular vectors
figure(4); clf
plot(vSW, uSW(:, 1:4))
title(sprintf('FOV %d SW NEdN first 4 left singular vectors', fi))
axis([2150, 2550, -0.15, 0.15])
legend('1', '2', '3', '4', 'location', 'south')
xlabel('wavenumber')
ylabel('weight')
grid on; zoom on
% saveas(gcf, 'SW_sing_vecs', 'png') 

% LW pre and post filter
figure(5); clf
plot(vLW, neLW1(:, si), vLW, neLW2(:, si), 'r')
axis([650, 1100, 0, 1])
title(sprintf('FOV %d LW NEdN sample values', fi))
legend('pre filter', 'post filter')
xlabel('wavenumber')
ylabel('d rad')
grid on; zoom on
% saveas(gcf, 'LW_pre_post', 'png') 

% MW pre and post filter
figure(6); clf
plot(vMW, neMW1(:, si), vMW, neMW2(:, si), 'r')
axis([1200, 1760, 0.04, 0.11])
title(sprintf('FOV %d MW NEdN sample values', fi))
legend('pre filter', 'post filter', 'location', 'northwest')
xlabel('wavenumber')
ylabel('d rad')
grid on; zoom on
% saveas(gcf, 'MW_pre_post', 'png') 

% SW pre and post filter
figure(7); clf
plot(vSW, neSW1(:, si), vSW, neSW2(:, si), 'r')
axis([2150, 2550, 0.008, 0.016])
title(sprintf('FOV %d SW NEdN sample values', fi))
legend('pre filter', 'post filter', 'location', 'southeast')
xlabel('wavenumber')
ylabel('d rad')
grid on; zoom on
% saveas(gcf, 'SW_pre_post', 'png') 

