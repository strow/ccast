%
%  get condition number of f * SA-1 *f
%

addpath ../source
addpath ../motmsc/utils

sfile = '../inst_data/SRF_v33a_HR2_Pn_SW.mat';

band = 'SW';
wlaser = 773.13;
opts = struct;
opts.resmode = 'hires2';
[inst, user] = inst_params(band, wlaser, opts);

% get SRF matrix for the current wlaser
Smat = getSRFwl(wlaser, sfile);

% take the inverse after interpolation
Sinv = zeros(inst.npts, inst.npts, 9);
for i = 1 : 9
  Sinv(:,:,i) = inv(squeeze(Smat(:,:,i)));
end

% get the bandpass filter as a matrix
F = diag(bandpass(inst.freq, ones(inst.npts,1), user.v1, user.v2, user.vr));

% check some condition numbers
cond(Sinv(:,:,1))
cond(Smat(:,:,1))
cond(Smat(:,:,2))
cond(Smat(:,:,5))

% the condition number for F * SA-1 * F is Inf, due to the zeros in
% the wings.
% cond(F * Sinv(:,:,fi) * F)

