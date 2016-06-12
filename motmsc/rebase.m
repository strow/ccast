%
% NAME
%   rebase - resampling with change of basis
%
% SYNOPSIS
%   [rad2, frq2] = finterp(inst, user, rad1, opt1)
%
% INPUTS
%   inst   - sensor grid struct
%   user   - user grid struct
%   rad1   - radiances, m x n array
%   opt1   - optional parameters
%
% opt fields
%   wrap  - 'sinc' (default), 'psinc n', 'psinc n*d'
%
% OUTPUTS
%   rad2   - resamples radiances, k x n array
%   frq2   - resampled frequencies, k-vector
%
% HM, 6 Jun 2016
%

% function [rad2, frq2] = rebase(inst, user, rad1, opt1)

% test setup
band = 'LW';
opt1 = struct;
opt1.user_res = 'hires';
opt1.inst_res = 'hires3';
wlaser = 773.13;
[inst, user] = inst_params(band, wlaser, opt1);

% get user grid spanning set
% k1 = floor(inst.freq(1) / user.dv);
% k2 = ceil(inst.freq(end) / user.dv);

% get user grid max subset
% k1 = ceil(inst.freq(1) / user.dv);
% k2 = floor(inst.freq(end) / user.dv);

% get spanning user grid with inst.npts
k1 = ceil(inst.freq(1) / user.dv) - 6;
k2 = k1 + inst.npts - 1;

frq2 = (k1 : k2)' * user.dv;

B = zeros(length(frq2), inst.npts);

for i = 1 : inst.npts

  vx2 = (frq2 - inst.freq(i)) / user.dv;

% B(:, i) = sinc(vx2);
% B(:, i) = 0.9836 * sinc(vx2);
% B(:, i) = psinc(vx2, inst.npts);
  B(:, i) =  0.9836 * psinc(vx2, inst.npts);

end

