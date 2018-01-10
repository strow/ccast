%
% NAME
%   pcorr2 - do a basic phase correction
%
% SYNOPSIS
%   [r2, t1] = pcorr2(r1);
%
% INPUTS
%   r1  - input radiances, m by n array
%
% OUTPUT
%   r2  - phase corrected output radiances
%   t1  - corresponding angles, in radians
%
% DISCUSSION
%
% AUTHOR
%   H. Motteler, 12 Jan 05
%

function [r2, t1] = pcorr2(r1);

% find the phase correction 
t1 = atan(imag(r1)./real(r1));

% apply the phase correction
r2 = abs(real(r1) .* cos(t1) + imag(r1) .* sin(t1));

% return 0 for complex 0
r2(find(real(r1) == 0 & imag(r1) == 0)) = 0;

