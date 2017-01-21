%
% NAME
%   nlc_poly - nonlinearity correction from polynomial fits
%
% SYNOPSIS
%   rout = nlc_poly(inst, rin, rsp, eng, gfun)
%
% INPUT
%   inst   - sensor grid struct
%   rin    - nchan x 9 input count spectra
%   rsp    - nchan x 9 space-look count spectra
%   eng    - current eng (4 min) packet struct
%   gfun   - polynomial gain functions
%
% OUTPUT
%   rdif   - nchan x 9 nonlinearity corrected rin - rsp
%
% DISCUSSION
%

function rdif = nlc_poly(inst, rin, rsp, eng, gfun)

% get a2 from inst or eng
if isfield(inst, 'a2') && ~isempty(inst.a2)
  a2 = inst.a2;
else
  a2 = eng.Linearity_Param.Band(bi).a2;
end

% band params
switch upper(inst.band)
  case 'LW', bi = 1; UW_NF_scale = 1.6047; iFOV = 5;
  case 'MW', bi = 2; UW_NF_scale = 0.9826; iFOV = 9;
  case 'SW', bi = 3; UW_NF_scale = 0.2046; iFOV = [];
  otherwise, error('bad band spec');
end

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
cm = cm(:); cp = cp(:); Vinst = Vinst(:);

% analog to digital gain
ca = 8192/2.5;

% combined gain factor 
cg = cm .* cp * ca * inst.df / 2;

% divide by the numeric filter
rin = rin ./ (inst.sNF(:) * ones(1, 9));
rsp = rsp ./ (inst.sNF(:) * ones(1, 9));

% divide by gain factors
rin = rin ./ (ones(inst.npts, 1) * cg');
rsp = rsp ./ (ones(inst.npts, 1) * cg');

% UW scaling factor
UW_fudge = (max(inst.sNF)/UW_NF_scale);

% no correction for the SW
if bi == 3
  rdif = rin - rsp;
end

% get the DC level
Vdc = Vinst + UW_fudge * mean(abs(rin - rsp))';
% Vlev = UW_fudge * mean(abs(rin - rsp))';
Vlev = mean(abs(rin - rsp))';

a2 = [
    0.015
    0.045
    0.070
    0.025
    0.031
    0.007
    0.260
    0.120
    0.008
];

onescol = ones(inst.npts, 1);

% first-order correction
% rdif1 = rin .* (ones(inst.npts, 1) * (1 + 2 * a2 .* Vdc)') ...
%       - rsp .* (ones(inst.npts, 1) * (1 + 2 * a2 .* Vinst)'); ...

rdif = (rin - rsp) .* (onescol  * (1 + 2 * a2 .* Vinst)') ...
     + rin .* (onescol  * (2 * a2 .* Vlev)');

% if ~isclose(rdif, rdif1), keyboard, end

% % second-order component
% Iin = spec2igm(rin, inst);
% Isp = spec2igm(rsp, inst);
% rin2 = igm2spec(Iin .* Iin, inst);
% rsp2 = igm2spec(Isp .* Isp, inst);
% % rtmp = ones(inst.npts, 1) * a2' .* (rin2 - rsp2);
%   rtmp = 0.12 * (rin2 - rsp2);
% % rdif = rdif + rtmp;
%   rdif = rdif - rtmp;

% ad hoc interferometric correction
%       1  2    3   4 5 6   7   8   9
  w1 = [1  1    1   1 1 1   1   1   1];
% w2 = [0 0.04 0.04 0 0 0 0.04 0.04 0];
  w2 = [0  0    0   0 0 0 0.04  0   0];
% w2 = [0  0    0   0 0 0   0   0   0];
  w3 = [0  0    0   0 0 0   0   0   0];

% w1 = [1 1 1 1 1 1 1.0015  1 1];
% w2 = [0 0 0 0 0 0 0.0282  0 0];
% w3 = [0 0 0 0 0 0 0.1515  0 0];

Itmp = spec2igm(rdif, inst);

for fi = 1 : 9
  Ix = Itmp(:, fi);
  Itmp(:, fi) = w1(fi) * Ix + w2(fi) * Ix.^2 + w3(fi) * Ix.^3;
end

% if bi == 2 && max(abs(Itmp(:))) > 0.133
%   fprintf(1, '%g\n', max(abs(Itmp(:))))
% end

rdif = igm2spec(Itmp, inst);

% rdif = rdif + igm2spec(Itmp, inst);

