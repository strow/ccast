
d12 = load('allsci_2012');
d13 = load('allsci_2013');
d14 = load('allsci_2014');
d15 = load('allsci_2015');
d16 = load('allsci_2016');

mtime =  [d12.mtime;  d13.mtime;  d14.mtime;  d15.mtime;  d16.mtime];
mlaser = [d12.mlaser; d13.mlaser; d14.mlaser; d15.mlaser; d16.mlaser];

% clear d12 d13 d14 d15 d16

save met_all.mat mtime mlaser

