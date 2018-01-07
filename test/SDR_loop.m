%
% SDR_loop - prototype j1/cris2 SDR read loop
%

cdir = '/asl/data/cris/ccast/SDR_j01_s45/2018/006';
flist = dir(fullfile(cdir, 'CrIS_SDR_j01_s45_*.mat'));

wlist = [];
wtime = [];

for i = 1 : length(flist)

  d1 = load(fullfile(flist(i).folder, flist(i).name));

  wlist = [wlist, d1.instLW.wlaser];
  wtime = [wtime, d1.geo.FORTime(1)];

  fprintf(1, '.')
end
fprintf(1, '\n')

plot(tx, wlist * 2, 'linewdith', 2)
datetick('x', 'HH')
ax = axis; ax(3) = 1547.2; ax(4) = 1548.4;
axis(ax)
title('met laser wavelength')
xlabel('6 Jan 2018, hour')
ylabel('wavelength, nm')
grid on

