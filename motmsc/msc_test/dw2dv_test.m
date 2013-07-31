% 
% dw2dv_test - compare wlaser and frequency residuals
%
% Let w be metrology laser wavelength, dw change in w, dv channel
% spacing, ddv change in channel spacing, vr a frequency you want 
% to check, and dvr the frequency shift at vr.  Get dv as a function 
% of w and differentiate to get ddv as a function of dw.  Then let 
% dvr = ddv * vr/dv and compare dvr gotten this way, starting with
% a 2 ppm dw, with a 2 ppm dvr specified directly.

addpath ../source
addpath utils

w = 773.1301;         % reference wlaser
dw = 2 * w / 1e6;     % +2 ppm of wlaser

vr = 1000;            % reference frequency
dvr = -2 * vr / 1e6;  % -2 ppm of ref freq

[inst, user] = inst_params('LW', w);     % get instrument params
dv = 1e7 / (inst.df * inst.npts * w);    % dv as a function of w
w1 = 1e7 / (inst.df * inst.npts * dv);   % w1 as a function of dv
c  = 1e7 / (inst.df * inst.npts);        % constant for this band

w2 = c / dv;    % w2 as a function of dv and c
dv1 = c / w2;   % dv1 as a function of w2 and c

ddv  = (-c/w^2) * dw;   % ddv as a function of dw
dw1 = (-c/dv^2) * ddv;  % dw1 as a function of ddv
dvr1 = ddv * vr / dv;   % dvr1 indirectly, from dw

% check that everything that should be close really is
k = 2;
[ isclose(w1, w, k), isclose(w2, w, k), isclose(dv1, dv, k), ...
  isclose(dw1, dw, k), isclose(dvr, dvr1, k)]

