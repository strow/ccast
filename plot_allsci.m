%
% sample plot of sci and eng data
%

% factor to convert MIT time to IET, t_mit * mwt = t_ngas
mwt = 8.64e7;

load('allsci20120209')   % allsci source file
dstr = '9 Feb 2012';    % date for plot title
fstr = strrep(dstr, ' ', '_');  % date string for save files

n = length(alleng);
etime = zeros(n, 1);
mtime = zeros(n, 1);
mlaser = zeros(n, 1);

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
figure(1)
plot((ptime-ptime(1))/ms_hr, mlaser, 'o')
title(sprintf('met laser vs eng packet time, %s', dstr))
xlabel('hour')
ylabel('met laser wavelength')
grid
saveas(gcf, ['met_', fstr], 'fig')


% plot ICT temps vs eng packet time
figure(2)
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



