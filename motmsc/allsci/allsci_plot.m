% 
% allsci_plot -- quick look at ICT and met laser values
%

addpath ../source
addpath ../davet
addpath time

% get a date
dnum = datenum(input('date > ', 's'));
dstr = datestr(dnum, 1); 

% path to allsci data
daily_mat = '/asl/data/cris/ccast/daily';

% load the allsci file
dtmp = datestr(dnum, 30);
sfile = fullfile(daily_mat, dtmp(1:4), ['allsci', dtmp(1:8), '.mat']);
load(sfile)

% ICT time and temps
ptime = utc2dnum([allsci(:).time] / 1000);
ptemp1 = [allsci(:).T_PRT1];
ptemp2 = [allsci(:).T_PRT2];

% met laser time and values
k = 0;
told = [];
mtime  = zeros(14, 1);
mlaser = zeros(14, 1);
neng = length(alleng);
for i = 1 : neng
  [lnew, tnew] = metlaser(alleng(i).NeonCal);
  if tnew == told
    continue
  end
  k = k + 1;
  told = tnew;
  mtime(k) = tnew;
  mlaser(k) = lnew;
end

mtime = mtime(1:k, 1);
mlaser = mlaser(1:k, 1);

figure(1); clf
subplot(2,1,1)
x1 = (mtime - mtime(1)) * 24 + 1;
plot(x1, mlaser, 'o')
title([dstr, ' met laser values'])
ylabel('wavelength')
grid

subplot(2,1,2)
x2 = (ptime - ptime(1)) * 24 + 1;
plot(x2, ptemp1, x2, ptemp2) 
title([dstr, ' ICT temps'])
legend('T\_PRT1', 'T\_PRT2', 'location', 'best')
xlabel('hour')
ylabel('ICT temp, K')
grid

% saveas(gcf, ['allsci_', dstr], 'png')

