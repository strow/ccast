%
% check sci pack time range ve obs time
%

load cdr_2017_221/SDR_test_179.mat

whos sci

s1 = datestr(iet2dnum(scTime(1)));
s2 = datestr(iet2dnum(scTime(end)));
s3 = datestr(utc2dnum(sci(1).time/1000));
s4 = datestr(utc2dnum(sci(end).time/1000));

display(['scTime ', s1, '  ', s2])
display(['scipak ', s3, '  ', s4])

