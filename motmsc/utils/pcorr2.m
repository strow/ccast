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
%   the calculation assumes r1 has a complex component with 
%   meaningful phase info; if r1 is real it is returned unchanged
%   note we don't actually need the frequency, as in pcorr1.m
%
% AUTHOR
%   H. Motteler, 12 Jan 05
%

function [r2, t1] = pcorr2(r1);

% find the phase correction 
warning off
t1 = atan(imag(r1)./real(r1));
warning on

% apply the phase correction
r2 = real(r1) .* cos(t1) + imag(r1) .* sin(t1);

