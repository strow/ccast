%
% NAME
%   pcorr3 - phase correction with unwrap
%
% SYNOPSIS
%   [r2, t1, t2] = pcorr3(r1);
%
% INPUTS
%   r1  - input radiances, m by n array
%
% OUTPUT
%   r2  - phase corrected output radiances
%   t1  - corresponding angles, in radians
%   t2  - t1 unwrapped, used for correction
%
% DISCUSSION
%   similar to pcorr2 but with matlat unwrap
%
% AUTHOR
%   H. Motteler, 28 Feb 08
%

function [r2, t1, t2] = pcorr3(r1);

% find the phase correction 
t1 = atan2(imag(r1), real(r1));
t2 = unwrap(t1);

% apply the phase correction
r2 = real(r1) .* cos(t2) + imag(r1) .* sin(t2);

