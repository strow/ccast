%
% check that the datenum call in packet header reader is not needed
%

sec_per_day = 60 * 60 * 24;

% day list from oct 2001 to 2018
dd = 16001 : 22000;
n = length(dd);

% make a randon seconds-of-day list
% k = sec_per_day - 1;
  k = 2*sec_per_day - 1;
ss = randi(k, 1, n);

t1 = datenum(0,0,dd,0,0,ss);

t2 = dd + ss / sec_per_day;

isequal(t1, t2)

