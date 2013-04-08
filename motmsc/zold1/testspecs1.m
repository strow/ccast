
band = 'SW'
wlaser = 773;
opts.nospec = 1;
opts.wlaser = wlaser;
[specX, freqX, optsX] = readspec6([], band, opts);

[inst, user] = inst_params(band, wlaser);

isequal(freqX, inst.freq)
isequal(optsX.cind, inst.cind)
isequal(optsX.vlaser, inst.vlaser)
isequal(optsX.dx, inst.dx)
isequal(optsX.mpd, inst.opd)

