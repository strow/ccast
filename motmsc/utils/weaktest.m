%
% demo of Daves weak sine apodization
%

addpath /home/motteler/cris/bcast/source

% sfile = 'SDR_d20120920_t0117090.mat';
  sfile = 'SDR_d20120920_t0813066.mat';
% sfile = 'SDR_d20120920_t2141021.mat';
% sfile = 'SDR_d20120920_t2221019.mat';

sdir1 = '/asl/data/cris/ccast/sdr60/2012/264';

band = 'SW';

sfile1 = fullfile(sdir1, sfile);
d1 = load(sfile1);

switch upper(band)
  case 'LW', r1 = d1.rLW; v1 = d1.vLW;
  case 'MW', r1 = d1.rMW; v1 = d1.vMW;
  case 'SW', r1 = d1.rSW; v1 = d1.vSW;
end

% rid for plot name
rid = sfile(5:22); rtmp = rid; rtmp(10) = ' ';

% get user grid
wlaser = 773.1301;
[inst, user] = inst_params(band, wlaser);
ix = find(user.v1 <= v1 & v1 <= user.v2);

% select a FOV, FOR, and scan
ifov = 1;
ifor = 15;
iscan = 31;

v1 = v1(ix)';
r2 = squeeze(r1(ix, ifov, ifor, iscan));

% call weaksine
frac_sine = 0.05;
[r3, apod] = weaksine(r2, frac_sine);

b2 = rad2bt(v1, r2);
b3 = rad2bt(v1, r3);

figure(1); clf;
subplot(2,1,1)
plot(v1, b2, v1, b3)
legend('boxcar', 'weak sine', 'location', 'best')
title(sprintf('sine frac = %g', frac_sine))
% xlabel('wavenumber')
ylabel('BT')
grid on; zoom on

% figure(2); clf
subplot(2,1,2)
plot(v1, b2 - b3)
title('boxcar - weak sine')
xlabel('wavenumber')
ylabel('dBT')
grid on; zoom on
saveas(gcf, sprintf('weak_sine_%s', band), 'fig')

figure(3); clf
n = length(v1);
x = (1:n) ./ n;
plot(x, apod);
ax(1) = 1 - 2*frac_sine;
ax(2) = 1;
ax(3) = 0;
ax(4) = 1.1;
axis(ax);
title('apodization tail')
grid on; zoom on
saveas(gcf, 'apod_tail', 'fig')

