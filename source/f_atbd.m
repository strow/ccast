%
% NAME
%   f_atbd -- return ATBD and related NOAA filters
%
% SYNOPSIS
%   f = f_atbd(b, k, t)
%
% INPUTS
%   b  - band number
%   k  - channel index
%   t  - 'atbd', 'noaa1', 'noaa2'
%
% OUTPUTS
%   f  - filter weights
%
% DISCUSSION
%   From the CrIS ATBD and Yong Han.  'atbd' is the stock low res
%   ATBD filter.  'noaa1' is a high res version of 'atbd' with added
%   guard points, and 'noaa2' a high res version with added guard
%   points and a broader passband

function f = f_atbd(b, k, t)

switch(t)
  case 'atbd' 
    % original ATBD weights
    np = [864  528  200];
    k0 = [ 77   49   22];
    k1 = [789  481  180];
    a1 = [ 15   22    8];
    a2 = [0.5  1.0  2.0];
    a3 = [ 15   22    8];
    a4 = [0.5  1.0  2.0];

  case 'noaa1' 
    % noaa old high res with guard points
    np = [866  1052   799];
    k0 = [ 78    95    84];
    k1 = [790   959   716];
    a1 = [ 15    44    32];
    a2 = [0.5   0.58  0.5];
    a3 = [ 15    44    32];
    a4 = [0.5   0.5   0.5];

  case 'noaa2' 
    % noaa new high res with guard points
    np = [866  1052   799];
    k0 = [ 78    95    84];
    k1 = [790   959   716];
    a1 = [ 30    59    41];
    a2 = [0.5   0.58  0.5];
    a3 = [ 30    59    41];
    a4 = [0.5   0.5   0.5];

  case 'noaa3' 
    % noaa new for extended res
    np = [874  1052   808];
    k0 = [ 79    95    85];
    k1 = [797   959   724];
    a1 = [ 30    59    41];
    a2 = [0.5   0.58  0.5];
    a3 = [ 30    59    41];
    a4 = [0.5   0.5   0.5];

  otherwise
    error(sprintf('unexpected filter type %s', t))
end

np = np(b); k0 = k0(b); k1 = k1(b);
a1 = a1(b); a2 = a2(b); a3 = a3(b); a4 = a4(b);

f = (1 ./ (exp(a2.*(k0-a1-k)) + 1)) .* (1 ./ (exp(a4.*(k-k1-a3)) + 1));

