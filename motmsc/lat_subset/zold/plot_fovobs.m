%
% plot_fovobs - CrIS FOV equal area obs count diffs
%

d1 = load('cris_obs_d1s1f1');
d2 = load('cris_obs_d1s1f9');

% nLat = 20;  dLon = 6;
  nLat = 24;  dLon = 4;
% nLat = 32;  dLon = 3;
% nLat = 36;  dLon = 2;

[latB1, lonB1, gtot1] = equal_area_bins(nLat, dLon, d1.slat, d1.slon);
[latB2, lonB2, gtot2] = equal_area_bins(nLat, dLon, d2.slat, d2.slon);

% gmean1 = mean(gtot1(:));
% gmean2 = mean(gtot2(:));
% grel1 = (gtot1 - gmean1) / gmean1;
% grel2 = (gtot2 - gmean2) / gmean2;
% gdiff = grel2 - grel1;

gdiff = gtot2 - gtot1;

tstr = 'FOV 9 minus 1 equal area obs counts';
equal_area_map(1, latB1, lonB1, gdiff, tstr);

tstr = 'FOV 1 equal area obs counts';
equal_area_map(2, latB1, lonB1, gtot1, tstr);

tstr = 'FOV 9 equal area obs counts';
equal_area_map(3, latB1, lonB1, gtot2, tstr);

