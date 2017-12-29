%
% quick comparison of old and new ccast, loop on matches
%

p1 = '/asl/data/cris/ccast/sdr60_hr/2017/073';
g1 = 'SDR_d20170314_t0616124.mat';
f1 = fullfile(p1, g1);

p2 = '/asl/data/cris/ccast/SDR_npp_s45/2017/073';
g2 = 'CrIS_SDR_npp_s45_d20170314_t0618080_c0a1bce.mat';
f2 = fullfile(p2, g2);

d1 = load(f1);
d2 = load(f2);

t1 = d1.geo.FORTime;
t2 = d2.geo.FORTime;

[datestr(iet2dnum(t1(1))), '  ', datestr(iet2dnum(t1(end)))]
[datestr(iet2dnum(t2(1))), '  ', datestr(iet2dnum(t2(end)))]

[j1, j2] = seq_match(t1(:), t2(:));
fprintf(1, 'found %d matches\n', length(j1))

% k = 27;
% datestr(iet2dnum(t1(j1(k))))
% datestr(iet2dnum(t2(j2(k))))

r1 = mod(j1-1, 30) + 1;
r2 = mod(j2-1, 30) + 1;
c1 = floor((j1-1)/30) + 1;
c2 = floor((j2-1)/30) + 1;

% datestr(iet2dnum(d1.geo.FORTime(r1(k), c1(k))))
% datestr(iet2dnum(d2.geo.FORTime(r2(k), c2(k))))

jFOV = 5;
x1 = d1.vLW;
for i = 1 : length(c1)
  datestr(iet2dnum(d1.geo.FORTime(r1(i), c1(i))))
  datestr(iet2dnum(d2.geo.FORTime(r2(i), c2(i))))
  y1 = d1.rLW(:, jFOV, r1(i), c1(i));
  y2 = d2.rLW(:, jFOV, r2(i), c2(i));
  b1 = rad2bt(x1, y1);
  b2 = rad2bt(x1, y2);
  plot(x1, b2 - b1)
  axis([650, 1150, -0.1, 0.1])
  pause
end

