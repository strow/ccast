%
% NAME
%   nlc_quad - nonlinearity correction with quadratic term
%
% SYNOPSIS
%   rout = nlc_new(inst, rin, rsp, eng)
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
%
%   identical with nlc_new except for the added quadratic term and
%   some commented out plotting at the end
%

function rout = nlc_quad(inst, rin, rsp, eng)

% band params
switch upper(inst.band)
  case 'LW', bi = 1;  UW_NF_scale = 1.6047;
  case 'MW', bi = 2;  UW_NF_scale = 0.9826;
  case 'SW', bi = 3;  UW_NF_scale = 0.2046;
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

% put eng params in column order
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

% get the DC level
Vdc = Vinst + UW_fudge * mean(abs(rin - rsp))';

% first-order correction
rout = rin .* (ones(inst.npts, 1) * (1 + 2 * a2 .* Vdc)');

% second-order component
Itmp = spec2igm(rin, inst);
rtmp = igm2spec(Itmp .* Itmp, inst);
rtmp = ones(inst.npts, 1) * a2' .* rtmp;
rout = rout + rtmp;

% figure(1)
% subplot(2,1,1)
% plot(inst.freq, abs(rout - rtmp))
% axis([1200, 1800, 0, 0.2])
% title('ICT with ATBD correction')
% ylabel('volts')
% grid on
% 
% subplot(2,1,2)
% plot(inst.freq, abs(rtmp))
% axis([1200, 1800, 0, 3e-4])
% title('quadratic term')
% ylabel('volts')
% xlabel('wavenumber')
% grid on
% saveas(gcf, 'ICT_with_quad', 'png')

% figure(1)
% j = 5;
% plot(inst.freq, abs(rout(:,j)), inst.freq, abs(rtmp(:,j)))
% plot(inst.freq, abs(rtmp(:,j)) ./ abs(rout(:,j)))

% figure(2)
% ix = 1 : inst.npts;
% plot(ix, abs(Itmp), ix, abs(Itmp .* Itmp))

