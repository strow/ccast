%
% nedn_svd1 -- NEdN svd and filter demo plots
%

% NEdN data
load nedn_tab

% parameters
nb = 8;     % number of basis vectors
si = 1;     % sweep direction (1 or 2)
fi = 1;     % specify a FOV (1 to 9)

neLW1 = squeeze(nLWtab(:, fi, si, :));
[u,s,v] = svd(neLW1, 0);
dLW = diag(s);
uLW = u(:, 1:nb);
filt = uLW * uLW';
neLW2 = filt * neLW1;

neMW1 = squeeze(nMWtab(:, fi, si, :));
[u,s,v] = svd(neMW1, 0);
dMW = diag(s);
uMW = u(:, 1:nb);
filt = uMW * uMW';
neMW2 = filt * neMW1;

neSW1 = squeeze(nSWtab(:, fi, si, :));
[u,s,v] = svd(neSW1, 0);
dSW = diag(s);
uSW = u(:, 1:nb);
filt = uSW * uSW';
neSW2 = filt * neSW1;

figure(1); clf
ix = 1 : 100;
loglog(ix, dLW(ix), ix, dMW(ix), ix, dSW(ix))
title(sprintf('FOV %d LW NEdN singular values', fi))
legend('LW', 'MW', 'SW')
xlabel('index')
ylabel('weight')
grid on; zoom on

figure(2); clf
plot(vLW, uLW(:, 1:4))
title(sprintf('FOV %d LW NEdN first 4 left singular vectors', fi))
legend('1', '2', '3', '4')
xlabel('wavenumber')
ylabel('weight')
grid on; zoom on

figure(3); clf
plot(vLW, neLW1(:, 91), vLW, neLW2(:, 91))
title(sprintf('FOV %d LW NEdN sample values', fi))
legend('pre filter', 'post filter')
xlabel('wavenumber')
ylabel('d rad')
grid on; zoom on

figure(4); clf
plot(vMW, neMW1(:, 91), vMW, neMW2(:, 91))
title(sprintf('FOV %d MW NEdN sample values', fi))
legend('pre filter', 'post filter')
xlabel('wavenumber')
ylabel('d rad')
grid on; zoom on

figure(5); clf
plot(vSW, neSW1(:, 91), vSW, neSW2(:, 91))
title(sprintf('FOV %d SW NEdN sample values', fi))
legend('pre filter', 'post filter')
xlabel('wavenumber')
ylabel('d rad')
grid on; zoom on
