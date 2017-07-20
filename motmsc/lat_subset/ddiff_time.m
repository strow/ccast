%
% ddiff_time - time double difference
%

addpath ./time

% d1 = load('cris_nosub_d1s1f1');
% d2 = load('cris_nosub_d1s1f9');
% d3 = load('cris_nosub_d2s1f1');
% d4 = load('cris_nosub_d2s1f9');

  d1 = load('cris_nosub_d3s1f1');
  d2 = load('cris_nosub_d3s1f9');
  d3 = load('cris_nosub_d4s1f1');
  d4 = load('cris_nosub_d4s1f9');

% d1 = load('cris_latsub_d1s1f1');
% d2 = load('cris_latsub_d1s1f9');
% d3 = load('cris_latsub_d2s1f1');
% d4 = load('cris_latsub_d2s1f9');

% d1 = load('cris_latsub_d3s1f1');
% d2 = load('cris_latsub_d3s1f9');
% d3 = load('cris_latsub_d4s1f1');
% d4 = load('cris_latsub_d4s1f9');

% nLat = 20;  dLon = 6;
  nLat = 24;  dLon = 4;

tbase1 = mean([mean(d1.stai), mean(d2.stai)]);
datestr(tai2dnum(tbase1))

tbase2 = mean([mean(d3.stai), mean(d4.stai)]);
datestr(tai2dnum(tbase2))

t1 = (d1.stai-tbase1) / (60 * 60 * 24);
t2 = (d2.stai-tbase1) / (60 * 60 * 24);
t3 = (d3.stai-tbase2) / (60 * 60 * 24);
t4 = (d4.stai-tbase2) / (60 * 60 * 24);

[latB1, lonB1, gtot1, gavg1] = equal_area_bins(nLat, dLon, d1.slat, d1.slon, t1);
[latB2, lonB2, gtot2, gavg2] = equal_area_bins(nLat, dLon, d2.slat, d2.slon, t2);
[latB3, lonB3, gtot3, gavg3] = equal_area_bins(nLat, dLon, d3.slat, d3.slon, t3);
[latB4, lonB4, gtot4, gavg4] = equal_area_bins(nLat, dLon, d4.slat, d4.slon, t4);

gdiff1 = gavg2 - gavg1;
gdiff2 = gavg4 - gavg3;
ddiff = gdiff2 - gdiff1;

tstr = 'obs time double difference';
equal_area_map(1, latB1, lonB1, ddiff, tstr);

return

tstr = 'FOV 9 minus 1 time diff 1';
equal_area_map(2, latB1, lonB1, gdiff1, tstr);

tstr = 'FOV 9 minus 1 time diff 2';
equal_area_map(3, latB1, lonB1, gdiff2, tstr);
