%
% NAME
%   nlc_vec - vectorized nonlineary correction
%
% SYNOPSIS
%   rout = nlc_vec(inst, rin, rsp, nopt)
%
% INPUT
%   inst   - sensor grid parameters
%   rin    - nchan x 9 input count spectra
%   rsp    - nchan x 9 space-look count spectra
%   nopt   - numeric filter, a1, cp, and Vinst
%
% OUTPUT
%   rout   - nchan x 9 nonlinearity corrected rin
%
% DISCUSSION
%   derived from the UW nlc.m
%

function rout = nlc_vec(inst, rin, rsp, nopt)

% divide inputs by the numeric filter
rin = rin ./ (nopt.sNF(:) * ones(1, 9));
rsp = rsp ./ (nopt.sNF(:) * ones(1, 9));

% correction parameters
a2 = nopt.a2;   % a2 correction weights
ca = 8192/2.5;  % analog to digital gain
cm = nopt.cm;   % modulation efficiency
cp = nopt.cp;   % PGA gain
Vinst = nopt.Vinst;

% get the DC level
Vdc = Vinst + 2*sum(abs(rin - rsp))' ./  (cm .* cp * ca * inst.npts * inst.df);

% first-order correction
rout = rin .* (ones(inst.npts, 1) * (1 + 2 * a2 .* Vdc)');

