%
% one-day mean ccast CrIS NEdN
%

addpath /home/motteler/cris/ccast/motmsc/utils
addpath /home/motteler/shome/airs_decon/test

% cdir = '/asl/cris/ccast/sdr45_npp_HR/2018/091';
cdir = './sdr45_j01_HR/2018/271';
flist = dir(fullfile(cdir, 'CrIS_SDR*.mat'));

for i = 1 : length(flist)

  cfile = fullfile(cdir, flist(i).name);
  d1 = load(cfile, 'nLW', 'nMW', 'nSW', 'vLW', 'vMW', 'vSW');

  ntmp1 = [d1.nLW(:,:,1); d1.nMW(:,:,1); d1.nSW(:,:,1)];
  ntmp2 = [d1.nLW(:,:,2); d1.nMW(:,:,2); d1.nSW(:,:,2)];

  if i == 1, 
    ncnt = 0;
    [m, n] = size(ntmp1);
    nsum1 = zeros(m, n);
    nsum2 = zeros(m, n);
  end

  ncnt = ncnt + 1;
  nsum1 = nsum1 + ntmp1;
  nsum2 = nsum2 + ntmp2;

  if mod(i, 10) == 0, fprintf(1, '.'), end
end
fprintf(1, '\n')

nedn1 = nsum1 / ncnt;
nedn2 = nsum2 / ncnt;
freq = [d1.vLW; d1.vMW; d1.vSW];

% save N20_HR_NEdN_all cdir ncnt nedn1 nedn2 freq

figure(1); clf
[x, y] = pen_lift(freq, nedn1);
semilogy(x, y)
axis([650, 2600, 0, 1])
title('N20 high res 1-day mean unapodized NEdN')
legend(fovnames)
set(gcf, 'DefaultAxesColorOrder', fovcolors);
xlabel('wavenumber, cm-1')
ylabel('NEdN, mw sr-1 m-2')
grid on

% saveas(gcf, 'N20_HR_NEdN_unap', 'png')

figure(2); clf
[x, y] = pen_lift(freq, nedn2);
semilogy(x, y, 'linewidth', 2)
% axis([650, 2600, 0, 1])
% axis([2150, 2550, 0, 6e-3])
  axis([2200, 2400, 0, 5e-3])
title('N20 high res 1-day mean apodized NEdN')
legend(fovnames)
set(gcf, 'DefaultAxesColorOrder', fovcolors);
xlabel('wavenumber, cm-1')
ylabel('NEdN, mw sr-1 m-2')
grid on

% saveas(gcf, 'N20_HR_NEdN_hamm', 'png')

