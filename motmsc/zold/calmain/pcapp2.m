%
% NAME
%   pcapp2 - apply a phase correction
%
% SYNOPSIS
%   r2 = pcapp2(r1, t1);
%
% INPUTS
%   r1  - input radiances, m by n array
%   t1  - corresponding angles, in radians
%
% OUTPUT
%   r2  - phase corrected output radiances
%

function r2 = pcapp2(r1, t1);

% apply the phase correction
r2 = abs(real(r1) .* cos(t1) + imag(r1) .* sin(t1));

% return 0 for complex 0
r2(find(real(r1) == 0 & imag(r1) == 0)) = 0;

