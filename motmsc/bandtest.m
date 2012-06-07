
% simple filter tests

vin = 1 : .5 : 40;
din = ones(length(vin),2);
v1 = 15; v2 = 25;

isequal(bandpass(vin, din, v1, v2), bandpass2(vin, din, v1, v2))

plot(vin, bandpass(vin, din, v1, v2, 10))


[inst, user] = inst_params('SW', 773.130);

vin = round(inst.freq(1)) + ((0 : inst.npts-1) * user.dv);

din = ones(inst.npts, 2);

plot(vin, bandpass(vin, din, user.v1, user.v2));
grid
zoom on

[vin(1), user.v1, user.v2, vin(end)]

