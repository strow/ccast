%
% ddif_obs - obs count double difference
%

% d1 = load('cris_latsub_d1s1f1');
% d2 = load('cris_latsub_d1s1f9');
% d3 = load('cris_latsub_d2s1f1');
% d4 = load('cris_latsub_d2s1f9');

d1 = load('cris_latsub_d3s1f1');
d2 = load('cris_latsub_d3s1f9');
d3 = load('cris_latsub_d4s1f1');
d4 = load('cris_latsub_d4s1f9');

% nLat = 20;  dLon = 6;
  nLat = 24;  dLon = 4;

[latB1, lonB1, gtot1] = equal_area_bins(nLat, dLon, d1.slat, d1.slon);
[latB2, lonB2, gtot2] = equal_area_bins(nLat, dLon, d2.slat, d2.slon);
[latB3, lonB3, gtot3] = equal_area_bins(nLat, dLon, d3.slat, d3.slon);
[latB4, lonB4, gtot4] = equal_area_bins(nLat, dLon, d4.slat, d4.slon);

gmean1 = mean(gtot1(:));
gmean2 = mean(gtot2(:));
gmean3 = mean(gtot3(:));
gmean4 = mean(gtot4(:));

grel1 = (gtot1 - gmean1) / gmean1;
grel2 = (gtot2 - gmean2) / gmean2;
grel3 = (gtot3 - gmean3) / gmean3;
grel4 = (gtot4 - gmean4) / gmean4;

gdiff1 = grel2 - grel1;
gdiff2 = grel4 - grel3;
ddiff = gdiff2 - gdiff1;

% gdiff1 = gtot2 - gtot1;
% gdiff2 = gtot4 - gtot3;
% ddiff = gdiff2 - gdiff1;

tstr = 'obs count double difference';
equal_area_map(1, latB1, lonB1, ddiff, tstr);
% caxis([-4, 4])

return

tstr = 'FOV 9 minus 1 obs diff 1';
equal_area_map(2, latB1, lonB1, gdiff1, tstr);
% caxis([-3, 3])

tstr = 'FOV 9 minus 1 obs diff 2';
equal_area_map(3, latB1, lonB1, gdiff2, tstr);
% caxis([-3, 3])

