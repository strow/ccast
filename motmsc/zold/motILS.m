%
% NAME
%   crisILS -- cris ILS function
%
% SYNOPSIS
%   ILS = crisILS(ifov, inst, vref, vgrid)
%
% INPUTS
%   ifov   - FOV index
%   inst   - cris sensor grid params
%   vref   - channel or reference frequency
%   vgrid  - output frequency grid
%
% OUTPUTS
%   ILS    - CrIS ILS at vgrid frequencies
%
% DISCUSSION
%   derived from cris_igm3, in the cris_sim repo.
%
% AUTHOR
%  H. Motteler, 14 May 2014
%

function ILS = motILS(ifov, inst, vref, vgrid)

narc = 2001;

a  = inst.foax(ifov);   % FOV off-axis angle
r2 = inst.frad(ifov);   % FOV radius
b = max(0, a - r2);     % min off-axis angle  
d = a + r2 - b;         % integral angle span

r1 = b : d/(narc-1) : a + r2;      % integral discrete angle steps
x = (a^2 + r1.^2 - r2^2) / (2*a);  % x val of FOV and arc intersection
alpha = real(acos(x ./ r1));       % angle to FOV and arc intersection 
w = alpha .* r1;                   % integral half-arc lengths

ILS = zeros(length(v), 1);

for i = 1 : narc
  ILS = ILS + w(i) * rsinc(2*pi*inst.opd*(v - v0*cos(r1(i))));
% ILS = ILS + w(i) * rsinc(2*pi*inst.opd*cos(r1(i)) * (v - v0*cos(r1(i))));
% ILS = ILS + w(i) * rsinc(2*pi*inst.opd*cos(r1(i)) * (v - v0));
end

ILS = ILS / sum(ILS);



