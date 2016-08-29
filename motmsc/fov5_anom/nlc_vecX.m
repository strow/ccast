%
% NAME
%   nlc_vec - vectorized nonlineary correction
%
% SYNOPSIS
%   rout = nlc_ng(inst, rin, rsp, eng)
%
% INPUT
%   inst   - sensor grid parameters
%   rin    - nchan x 9 input count spectra
%   rsp    - nchan x 9 space-look count spectra
%   eng    - current eng (4 min) packet struct
%
% OUTPUT
%   rout   - nchan x 9 nonlinearity corrected rin
%
% DISCUSSION
%   derived from the UW nlc.m
%

function rout = nlc_vec(inst, rin, rsp, eng)

% band index
switch upper(inst.band)
  case 'LW', bi = 1;
  case 'MW', bi = 2;  
  case 'SW', bi = 3;
  otherwise, error('bad band spec');
end

% normalize NF to match Dave's 2008 filter
switch upper(inst.band)
  case 'LW',  inst.sNF = 1.6047 * inst.sNF ./ max(inst.sNF);
  case 'MW',  inst.sNF = 0.9826 * inst.sNF ./ max(inst.sNF);
  case 'SW',  inst.sNF = 0.2046 * inst.sNF ./ max(inst.sNF);
end

% divide inputs by the numerical filter
rin = rin ./ (inst.sNF(:) * ones(1, 9));
rsp = rsp ./ (inst.sNF(:) * ones(1, 9));

% get a2 from inst or eng
if isfield(inst, 'a2') && ~isempty(inst.a2)
  a2 = inst.a2;
else
  a2 = eng.Linearity_Param.Band(bi).a2;
end

% get params from eng
cm = eng.Modulation_eff.Band(bi).Eff;
cp = eng.PGA_Gain.Band(bi).map(eng.PGA_Gain.Band(bi).Setting+1);
Vinst = eng.Linearity_Param.Band(bi).Vinst;

% put vectors in column order
a2 = a2(:);
cm = cm(:);
cp = cp(:);
Vinst = Vinst(:);

% analog to digital gain
ca = 8192/2.5;

% get the DC level
Vdc = Vinst + 2*sum(abs(rin - rsp))' ./  (cm .* cp * ca * inst.npts * inst.df);

% first-order correction
rout = rin .* (ones(inst.npts, 1) * (1 + 2 * a2 .* Vdc)');

save nlc_xxx Vdc Vinst a2 cm ca cp

