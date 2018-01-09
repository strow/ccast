%
% fp_from_eng - return a2 values from an eng packet
%
% SYNOPSIS
%   fp = fp_from_eng(eng)
%
% INPUT
%   eng  - eng packet from the MIT reader
%
% OUTPUT
%   a2   - 9 x 3 eng a2 values
% 

function a2 = a2_from_eng(eng)

a2 = NaN(9,3);
for bi = 1 : 3
 a2(:,bi) = eng.Linearity_Param.Band(bi).a2;
end

