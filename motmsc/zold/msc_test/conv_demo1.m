
% demo of kcarta convolutions with finterp
%

% sample kcarta data
% kcfile = '/home/motteler/cris/sergio/JUNK2012/convolved_kcarta25.mat';
kcfile = '/home/motteler/cris/sergio/JUNK2012/convolved_kcarta13.mat';
d1 = load(kcfile);

% get instrument and user grid params for adjusted wlaser
% (wlaser doesn't matter for instrument grid)
band = 'LW';
wlaser = 773.1301;
[inst, user] = inst_params(band, wlaser);

[rad2, frq2] = finterp(d1.r, d1.w, user.dv);

rad3 = bandpass(frq2, rad2, user.v1, user.v2, 20);

plot(frq2, real(rad2bt(frq2, rad3)))

