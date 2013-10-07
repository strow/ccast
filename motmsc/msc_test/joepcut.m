%
% compare Joe Predina's spreadsheet calcs with inst_params.m
%
% most of the substitutions are staightforward but note the use 
% of inst.vbase (which is 1 for bands 1 and 2 and 4 for band 3) 
% and which folds the three spreadsheet cases into one.
%

addpath /home/motteler/cris/bcast/source
addpath /home/motteler/cris/bcast/motmsc/utils

band = 'LW';
wlaser = 773.1301;
% wlaser = 1550.39 / 2;
opt.resmode = 'lowres';
[inst, user] = inst_params(band, wlaser, opt);
awidth = inst.vlaser / inst.df;

% plug inst_params values into Joe P's spreadsheet calc
d30 = wlaser;                   % met laser half-wavelength
d33 = inst.npts;                % number of transform points
d32 = inst.df;                  % decimation factor
d37 = (user.v1 + user.v2) / 2;  % band center
d31 = d32 * d33;                % number of undecimated points
d34 = -d30*(d31/2)*1e-7;        % -OPD
e34 = -d34;                     % +OPD
d35 = 1/(2*e34);                % dv 
d36 = d35 * d33;                % alias width
d38 = d37 - d36/2;              % desired first channel center
d9 = mod(round(d38/d35),d33);   % cut point
e9 = (d33*inst.vbase + d9) * d35; % first channel center
e17 = (d33*(inst.vbase+1) + d9 - 1) * d35; % last channel center

% check
[ isclose(inst.opd, e34), ...
  isclose(inst.dv, d35), ...
  isclose(inst.awidth, d36), ...
  isclose(inst.cutpt, d9), ...
  isclose(inst.vdfc, d38), ...
  isclose(inst.freq(1), e9), ...
  isclose(inst.freq(end), e17) ]

