%
% fp_from_eng - return focal plane spec from an eng packet
%
% SYNOPSIS
%   fp = fp_from_eng(eng)
%
% INPUT
%   eng  - eng packet from the MIT reader
%
% OUTPUT
%   fp.rad   - 9 x 3 FOV radii, urad
%   fp.pos   - 9 x 2 x 3 FOV x-y position, urad
%   fp.dxy   - 2 x 3 focal plane x-y shift, urad
%   fp.foax  - 9 x 3 FOV off-axis angles, rad
%   fp.frad  - 9 x 3 FOV radii, rad
%
%   the last index is the band
% 

function fp = fp_from_eng(eng)

% vals from eng, in microradians
rad = NaN(9, 3);    % FOV radii
pos = NaN(9, 2, 3); % FOV x-y positions
dxy = NaN(2, 3);    % x-y common offset

% values for the ILS calc, in radians
frad = NaN(9, 3);   % FOV radii, radians
foax = NaN(9, 3);   % FOV off axis angles, radians

for b = 1 : 3
  for i = 1 : 9
    rad(i,b) = eng.ILS_Param.Band(b).FOV(i).FOV_Size / 2;
    pos(i,1,b) = eng.ILS_Param.Band(b).FOV(i).CrTrkOffset;
    pos(i,2,b) = eng.ILS_Param.Band(b).FOV(i).InTrkOffset;
  end
  dxy(1,b) = eng.ILS_Param.Band(b).FOV5_CrTrkMisalignment;
  dxy(2,b) = eng.ILS_Param.Band(b).FOV5_InTrkMisalignment;

  foax(:,b) = sqrt((pos(:,1,b) + dxy(1,b)).^2 + (pos(:,2,b) + dxy(2,b)).^2);
end

fp.rad = rad;
fp.pos = pos;
fp.dxy = dxy;
fp.frad = rad * 1e-6;
fp.foax = foax * 1e-6;


