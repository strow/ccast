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

% band params
switch upper(inst.band)
  case 'LW', bi = 1; iFOV = 5;
  case 'MW', bi = 2; iFOV = 9;
  case 'SW', bi = 3; iFOV = [];
  otherwise, error('bad band spec');
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

% translate to interferograms
Idif = spec2igm(rin - rsp, inst);

% test code
% Isrc = Idif;

% apply the corrections
for fi = 1 : 9
  Idif(:, fi) = ...
    polyval(gfun.L1(:, gfun.iLin), polyval(gfun.Q1(:, fi), Idif(:,fi))) ...
      - gfun.LQ1(fi);
end

rdif = igm2spec(Idif, inst);

% ix = 1:1052;
% plot(ix, abs(Isrc), ix, abs(Idif))
% pause



