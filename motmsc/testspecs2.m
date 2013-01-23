
band = 'LW'
wlaser = 773;
[user,sensor] = spectral_params(band,wlaser);

[inst, user] = inst_params(band, wlaser);

rms(sensor.v_onaxis - inst.freq)
isequal(sensor.flipindex, inst.cind)
isequal(sensor.vlaser, inst.vlaser)
isequal(sensor.dx_onaxis, inst.dx)
isequal(sensor.MOPD_onaxis, inst.opd)

