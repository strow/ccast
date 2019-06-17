
sdir = 0;
ifov = 1;

f1 = '/asl/cris/tvac_2014/2013-06-13_ILS/nadir_stare.mat';
f2 = '/asl/cris/tvac_2014/2013-06-13_ILS/space_stare.mat';
f3 = '/asl/cris/tvac_2014/2013-06-13_ILS/laser_off.mat';

d1 = load(f1);
d2 = load(f2);
d3 = load(f3);

igm1 = d1.idata.LWES + 1i * d1.qdata.LWES;
ix = find(d1.sweep_direction.LWES(5, :) == sdir);
igm1 = squeeze(igm1(ifov,:,ix));

igm2 = d2.idata.LWSP + 1i * d2.qdata.LWSP;
ix = find(d2.sweep_direction.LWSP(5, :) == sdir);
igm2 = squeeze(igm2(ifov,:,ix));

igm3 = d1.idata.LWSP + 1i * d3.qdata.LWSP;
ix = find(d3.sweep_direction.LWES(5, :) == sdir);
igm3 = squeeze(igm3(ifov,:,ix));

% get instrument params
band = 'LW';
wlaser = 774.2020;
opt1 = struct;
opt1.resmode = 'hires2';
[inst, user] = inst_params(band, wlaser,opt1);

% translate to count spectra
spec1 = igm2spec(igm1, inst);
spec2 = igm2spec(igm2, inst);
spec3 = igm2spec(igm3, inst);

plot(inst.freq, abs(spec1(:,200) - spec2(:,200)))
