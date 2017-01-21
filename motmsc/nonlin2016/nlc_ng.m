%
% NAME
%   nlc_ng - nonlineary correction
%
% SYNOPSIS
%   rout = nlc_ng(inst, ifov, rin, rsp, eng)
%
% INPUT
%   inst   - sensor grid parameters
%   ifov   - FOV index, 1 to 9
%   rin    - nchan x 1 input count spectra
%   rsp    - nchan x 1 space look count spectra
%   eng    - current eng (4 min) packet struct
%
% OUTPUT
%   rout   -  Nonlinearity corrected scene spectrum (Nchan x 1)
% 
% DISCUSSION
%   non-vectoriezed test version, derived from the UW nlc.m
%

function rout = nlc_ng(inst, ifov, rin, rsp, eng)

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

% divide the complex spectra by the numerical filter
rin = rin ./ inst.sNF;
rsp = rsp ./ inst.sNF;

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

% choose a single FOV (for now...)
a2 = a2(ifov);
cp = cp(ifov); 
cm = cm(ifov); 
Vinst = Vinst(ifov); 

% analog to digital gain
ca = 8192/2.5;

% get the DC level
Vdc = Vinst + 2*sum(abs(rin - rsp)) / (cm * cp * ca * inst.npts * inst.df);

% first-order correction
rout = rin * (1 + 2 * a2 * Vdc);

