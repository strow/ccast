%
% SDR_loop - prototype j1/cris2 SDR read loop
%

addpath ../motmsc/time

ydir = '/asl/data/cris/ccast/sdr45_j01_HR/2018/';

wlist = [];
wtime = [];

for doy = 12 : 13
  dstr = sprintf('%03d', doy)
  flist = dir(fullfile(ydir, dstr, 'CrIS_SDR_j01_s45_*.mat'));
  for i = 1 : length(flist)
    d1 = load(fullfile(flist(i).folder, flist(i).name));
    wlist = [wlist, d1.instLW.wlaser];
    wtime = [wtime, d1.geo.FORTime(1)];
    fprintf(1, '.')
  end
  fprintf(1, '\n')
end

save SDR_loop wlist wtime ydir

return

tx = iet2dnum(wtime);
plot(tx, wlist * 2, 'linewidth', 2)
datetick('x', 'HH')
% ax = axis; ax(3) = 1547.2; ax(4) = 1548.4;
% axis(ax)
title('met laser wavelength')
xlabel('12-13 Jan 2018, hour')
ylabel('wavelength, nm')
grid on

