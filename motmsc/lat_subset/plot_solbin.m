%
% plot_solbin - equal area solar zenith stats
%

d1 = load('airs_sol_d1s2w1');
d2 = load('cris_sol_d1s2w1');

j1 = d1.ssol < 70;
j2 = d2.ssol < 70;

slat1 = d1.slat(j1);
slon1 = d1.slon(j1);
ssol1 = d1.ssol(j1);

slat2 = d2.slat(j2);
slon2 = d2.slon(j2);
ssol2 = d2.ssol(j2);

% nLat = 20;  dLon = 6;
  nLat = 24;  dLon = 4;

[latB1, lonB1, gtot1, gavg1] = ...
    equal_area_bins(nLat, dLon, slat1, slon1, sec(deg2rad(ssol1)));

[latB2, lonB2, gtot2, gavg2] = ...
    equal_area_bins(nLat, dLon, slat2, slon2, sec(deg2rad(ssol2)));

gdiff = gavg2 - gavg1;

tstr = 'CrIS minus AIRS mean solar zenith secants';
equal_area_map(1, latB1, lonB1, gdiff, tstr);

tstr = 'AIRS mean solar zenith secants';
equal_area_map(2, latB1, lonB1, gavg1, tstr);

tstr = 'CrIS mean solar zenith secants'
equal_area_map(3, latB1, lonB1, gavg2, tstr);

