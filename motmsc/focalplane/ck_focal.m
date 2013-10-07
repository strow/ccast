
addpath ../source

wlaser = 773.1301; band = 'LW';
[inst, user] = inst_params(band, wlaser);
% load dg_lw_v33b_adl.mat
load dg_v33a_lw.mat
(dg.Rtheta - inst.frad(1)) ./ inst.frad(1)
(dg.s' - inst.foax) ./ inst.foax

wlaser = 773.1301; band = 'MW';
[inst, user] = inst_params(band, wlaser);
% load dg_mw_v33b_adl.mat
load dg_v33a_mw.mat
(dg.Rtheta - inst.frad(1)) ./ inst.frad(1)
(dg.s' - inst.foax) ./ inst.foax

wlaser = 773.1301; band = 'SW';
[inst, user] = inst_params(band, wlaser);
% load dg_sw_v33b_adl.mat
load dg_v33a_sw.mat
(dg.Rtheta - inst.frad(1)) ./ inst.frad(1)
(dg.s' - inst.foax) ./ inst.foax

