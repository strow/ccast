% 
% sample plots of sci and eng data
%
%   - enter a date
%   - read allsci<yyyymmdd>.mat for that date
%   - plot ICT temperatures 1 & 2 vs time (hours)
%   - plot metrology laser wavelength vs time (hours)
% 

addpath ../davet

% factor to convert MIT to IET time
mwt = 8.64e7;

% path to allsci data
daily_mat = '/asl/data/cris/ccast/daily/2013';

% get matlab date number
dnum = datenum(input('date > ', 's'));

% load the allsci file
tmp = datestr(dnum, 30);
scifile = fullfile(daily_mat, ['allsci', tmp(1:8), '.mat']);
load(scifile)

dstr = datestr(dnum, 1);   % date for plot title 
fstr = tmp(1:8);           % date string for save files

n = length(alleng);
etime  = zeros(n, 1);
mtime  = zeros(n, 1);
mlaser = zeros(n, 1);
ptime  = zeros(n, 1);

% loop on eng records
for i = 1 : n
  % mtime is time from Neon Cal fields, matlab units?
  [mlaser(i), mtime(i)] = metlaser(alleng(i).NeonCal);

  % eng packet start time, in milliseconds since 1958
  ptime(i) = alleng(i).four_min_eng.time(1);
end

% milliseconds/hour, conversion factor for plots
ms_hr = 1000 * 60 * 60;

% plot met laser vs eng packet time
figure(1); clf
plot((ptime-ptime(1))/ms_hr, mlaser, 'o')
title(sprintf('met laser vs eng packet time, %s', dstr))
xlabel('hour')
ylabel('met laser wavelength')
grid
saveas(gcf, ['met_', fstr], 'fig')

% plot ICT temps vs eng packet time
figure(2); clf
xx1 = [allsci(:).time];
xx1 = (xx1 - xx1(1)) / ms_hr;
yy1 = [allsci(:).T_PRT1];
yy2 = [allsci(:).T_PRT2];
plot(xx1, yy1, xx1, yy2)
title(sprintf('ICT temps vs eng packet time, %s', dstr))
legend('T_PRT1', 'T_PRT2', 'location', 'best')
xlabel('hour')
ylabel('ICT temperature')
grid
saveas(gcf, ['ict_', fstr], 'fig')



