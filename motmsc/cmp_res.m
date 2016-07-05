%
% cmp_res - compare ccast hi2low with user-grid finterp
%

gran = 'SDR_d20150101_t0036413.mat';
f1 = fullfile('/asl/data/cris/ccast/sdr60_hr/2015/001', gran);
f2 = fullfile('/asl/data/cris/ccast/sdr60/2015/001', gran);

d1 = load(f1);
d2 = load(f2);

iscan = 31;
iFOR  = 15;
iFOV  = 5;

% MW plot
v1 = d1.vMW; v2 = d2.vMW;
bt1 = real(rad2bt(v1, d1.rMW(:, iFOV, iFOR, iscan)));
bt2 = real(rad2bt(v2, d2.rMW(:, iFOV, iFOR, iscan)));

uv1 = d2.userMW.v1; uv2 = d2.userMW.v2; udv = d2.userMW.dv;
[rtmp, v3] = finterp(d1.rMW(:, iFOV, iFOR, iscan), v1, udv);
bt3 = real(rad2bt(v3, rtmp));

figure(1); clf
plot(v1, bt1, v2, bt2, v3, bt3, [uv1, uv2], [bt2(1), bt2(end)], '+')
legend('hi res', 'hi2low', 'finterp', 'user grid', 'location', 'northheast')
grid on; zoom on

% SW plot
v1 = d1.vSW; v2 = d2.vSW;
bt1 = real(rad2bt(v1, d1.rSW(:, iFOV, iFOR, iscan)));
bt2 = real(rad2bt(v2, d2.rSW(:, iFOV, iFOR, iscan)));

uv1 = d2.userSW.v1; uv2 = d2.userSW.v2; udv = d2.userSW.dv;
[rtmp, v3] = finterp(d1.rSW(:, iFOV, iFOR, iscan), v1, udv);
bt3 = real(rad2bt(v3, rtmp));

figure(2); clf
plot(v1, bt1, v2, bt2, v3, bt3, [uv1, uv2], [bt2(1), bt2(end)], '+')
legend('hi res', 'hi2low', 'finterp', 'user grid', 'location', 'southeast')
grid on; zoom on

