%
% interpolation demo
%

addpath ../source
addpath ../motmsc/time
addpath ../motmsc/utils
addpath /asl/packages/airs_decon/source

p1 = '/asl/data/cris/ccast/sdr45_j01_HR/2018/060';
gran = 'CrIS_SDR_j01_s45_d20180301_t0118080_g014_v20a.mat';
f1 = fullfile(p1, gran);
d1 = load(f1);

t1 = d1.geo.FORTime;
[datestr(iet2dnum(t1(1))), '  ', datestr(iet2dnum(t1(end)))]
[d1.geo.Latitude(1), d1.geo.Longitude(1)]

vMW = d1.vMW;
rMW = d1.rMW(:, 5, 15, 22);

% AIRS-to-CrIS proposed MW res
dx06 = 0.6;
dv06 = 1 / (2*dx06);
[r06, v06] = finterp(rMW, vMW, dv06);
[rW, vW] = finterp2(r06, v06, 8);
bW = real(rad2bt(vW, rW));

% interp back up to 0.8 cm
dvY = 0.625;
[rY, vY] = finterp(r06, v06, dvY);
[rZ, vZ] = finterp2(rY, vY, 6);
bZ = real(rad2bt(vZ, rZ));

plot(vZ, bZ, vW, bW)
legend('0.6 cm oversamp at 0.8 cm', '0.6 cm at native 0.6 cm res')

return

[ix, iy] = seq_match(vMW, vY);
vX = vMW(ix); rX = rMW(ix); 
vY = vY(iy); rY = rY(iy);

bX = real(rad2bt(vX, hamm_app(double(rX))));
bY = real(rad2bt(vY, hamm_app(double(rY))));

plot(vX, bY - bX)
axis([1200, 1750, -10, 10])
grid on; zoom on

return

% finterp vs finterp2 test
sfac = 6;
dvY = dv06 / sfac;
[rX, vX] = finterp2(r06, v06, sfac);
[rY, vY] = finterp(r06, v06, dvY);

[ix, iy] = seq_match(vX, vY);
vX = vX(ix); rX = rX(ix); 
vY = vY(iy); rY = rY(iy);

bX = real(rad2bt(vX, rX));
bY = real(rad2bt(vY, rY));

plot(vX, bY - bX)
axis([1200, 1750, -10, 10])
