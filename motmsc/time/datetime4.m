% 
% test of dtm2utc
%

% d1 = [2012  6 30 23 59 59];
% d1 = [2012  7  1  0  0  0];
% d1 = [1972  7  1 13 31 19];
% d1 = [1971 12 31 23 59 59];
% d1 = [1972  1  1  0  0  0];
% d1 = [1994  3 13  7 33 13];

  d1 = [2015  6  3 23 59  9;
        2015  7  3 23 59  9];

t1 = utc2tai(dnum2utc(datenum(d1)));

t2 = dtime2tai(datetime(d1));

if isequal(t1, t2)
  fprintf(1, 'residual is zero\n')
else
  fprintf(1, 'residual %.3g seconds\n', t2 - t1)
end


d2 = ones(60, 1) * [1994  3 13  7 33 13];
d2(:, 5) = 0:59;
dnum2  = datenum(d2);
utc2   = dnum2utc(dnum2);
dtime2 = datetime(d2);

profile on

for i = 1 : 1000
% t1 = utc2tai(utc2);
  t1 = utc2tai(dnum2utc(dnum2));
  t2 = dtime2tai(dtime2);
end

profile report

