%
% check sci pack time range ve obs time
%

load L1a_2017_224/CrIS_L1a_j01_s45_d20170812_t0015520_c0a1bce.mat

whos sci

s1 = datestr(iet2dnum(scTime(1)));
s2 = datestr(iet2dnum(scTime(end)));
s3 = datestr(utc2dnum(sci(1).time/1000));
s4 = datestr(utc2dnum(sci(end).time/1000));

display(['scTime ', s1, '  ', s2])
display(['scipak ', s3, '  ', s4])

