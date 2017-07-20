%
% extend_time - compare 16 and 32 day sequences
%

addpath ./time

d3 = load('cris_nosub_d3s1f1');
d4 = load('cris_nosub_d4s1f1');

lat16 = d3.slat;
lon16 = d3.slon;
tai16 = d3.stai;
lat32 = [d3.slat; d4.slat];
lon32 = [d3.slon; d4.slon];
tai32 = [d3.stai; d4.stai];

tbase16 = mean(tai16);
datestr(tai2dnum(tai16(1)))
datestr(tai2dnum(tbase16))

tbase32 = mean(tai32);
datestr(tai2dnum(tai32(1)))
datestr(tai2dnum(tbase32))

t16 = (tai16-tbase16) / (60 * 60 * 24);
t32 = (tai32-tbase32) / (60 * 60 * 24);

% nLat = 20;  dLon = 6;
  nLat = 24;  dLon = 4;

[latB1,lonB1,gtot16,gavg16] = equal_area_bins(nLat,dLon,lat16,lon16,t16);
[latB2,lonB2,gtot32,gavg32] = equal_area_bins(nLat,dLon,lat32,lon32,t32);

tstr1 = 'FOV 1 16 day';
equal_area_map(1, latB1, lonB1, gavg16, tstr1);
caxis([-4, 4])

tstr2 = 'FOV 1 32 day';
equal_area_map(2, latB1, lonB1, gavg32, tstr2);
caxis([-4, 4])

tstr3 = 'FOV 1 32 day minus 16 day'
equal_area_map(3, latB1, lonB1, gavg32 - gavg16, tstr3);
caxis([-0.6, 0.6])


