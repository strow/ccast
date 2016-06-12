%
% resampling tests
%

% get CrIS user struct
band = 'LW';
opt1 = struct;
opt1.user_res = 'hires';
opt1.inst_res = 'hires3';
wlaser = 773.13;
[inst, user] = inst_params(band, wlaser, opt1);

[R3, frq] = resamp(inst, user, 3);
[R4, frq] = resamp(inst, user, 4);
[R5, frq] = resamp(inst, user, 5);

