
addpath ../source

d1 = load('ict_old_trends_N_polar');
d2 = load('ict_new_trends_N_polar');

[j1, j2] = seq_match(d1.dnum_list, d2.dnum_list);

ict1 = d1.ict_list(j1);
ict2 = d2.ict_list(j2);

dnum = d1.dnum_list(j1);

dax = datetime(dnum, 'ConvertFrom', 'datenum');

plot(dax, ict1 - ict2)

