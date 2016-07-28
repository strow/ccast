% 
% allsci_tab -- summary ICT and met laser data from daily files
%
% the time arrays mtime and ptime are saved as matlab datenums
%

addpath ../davet
addpath ../source
addpath time

% get the year
% year = '2015';
year = input('year > ', 's');

% path to allsci data
daily_dir = '/asl/data/cris/ccast/daily';

flist = dir(fullfile(daily_dir, year, 'allsci*.mat'));
nday = length(flist);

mtime  = zeros(nday * 14, 1);
mlaser = zeros(nday * 14, 1);

ptime = zeros(nday * 10800, 1);
ptemp1 = zeros(nday * 10800, 1);
ptemp2 = zeros(nday * 10800, 1);

% loop on days
j = 0;
k = 0;
told = [];
for di = 1 : nday

  % load allsci file for day di
  ftmp = fullfile(daily_dir, year, flist(di).name);
  load(ftmp)

  % loop on sci records
  nsci = length(allsci);
  for i = 1 : nsci
    % save PRT temp values
    j = j + 1;
    ptime(j) = utc2dnum(allsci(i).time / 1000);
    ptemp1(j) = allsci(i).T_PRT1;
    ptemp2(j) = allsci(i).T_PRT2;
  end

  % loop on eng records
  neng = length(alleng);
  for i = 1 : neng
    % save new met laser values
    [lnew, tnew] = metlaser(alleng(i).NeonCal);
    if tnew == told
      continue
    end
    k = k + 1;
    told = tnew;
    mtime(k) = tnew;
    mlaser(k) = lnew;

  end
  if mod(di, 10) == 0, fprintf(1, '.'), end
end
fprintf(1, '\n')

mtime = mtime(1:k, 1);
mlaser = mlaser(1:k, 1);
ix = find(~isnan(mlaser));
mlaser = mlaser(ix, 1);
mtime = mtime(ix, 1);

ptime = ptime(1:j, 1);
ptemp1 = ptemp1(1:j, 1);
ptemp2 = ptemp2(1:j, 1);
ix = find(~isnan(ptemp1));
ptime = ptime(ix, 1);
ptemp1 = ptemp1(ix, 1);
ptemp2 = ptemp2(ix, 1);

save(['allsci_',year], 'mtime', 'mlaser', 'ptime', 'ptemp1', 'ptemp2')

figure(1)
subplot(2,1,1)
plot(mtime - mtime(1) + 1, mlaser)
axis([1, 365, 773.128, 773.132])
title([year,' met laser values'])
xlabel('day')
ylabel('wavelength')
grid on; zoom on

subplot(2,1,2)
plot(ptime - ptime(1) + 1, ptemp1)
axis([1, 365, 279, 282])
title([year,' ICT temp 1'])
xlabel('day')
ylabel('ICT temp, K')
grid on; zoom on


