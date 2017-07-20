%
% plot_obsbin - cris minus airs equal area obs
%

d1 = load('airs_obs_d1s2w1');
d2 = load('cris_obs_d1s2w1');

% nLat = 20;  dLon = 6;
  nLat = 24;  dLon = 4;
[latB1, lonB1, gtot1] = equal_area_bins(nLat, dLon, d1.slat, d1.slon);
[latB2, lonB2, gtot2] = equal_area_bins(nLat, dLon, d2.slat, d2.slon);

% na = length(d1.slat);
% nc = length(d2.slat);
% gmean1 = mean(gtot1(:));
% gdiff = ((na/nc) * gtot2 - gtot1) ./ gmean1;

gmean1 = mean(gtot1(:));
gmean2 = mean(gtot2(:));
grel1 = (gtot1 - gmean1) / gmean1;
grel2 = (gtot2 - gmean2) / gmean2;
gdiff = grel2 - grel1;

tstr = 'CrIS minus AIRS equal area relative';
equal_area_map(1, latB1, lonB1, gdiff, tstr);

tstr = 'AIRS equal area relative';
equal_area_map(2, latB1, lonB1, grel1, tstr);

tstr = 'CrIS equal area relative';
equal_area_map(3, latB1, lonB1, grel2, tstr);



