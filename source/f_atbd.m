%
% NAME
%   f_atbd -- return ATBD and related NOAA filters
%
% SYNOPSIS
%   f = f_atbd(inst)
%
% INPUTS
%   inst - sensor grid parameters
%
% OUTPUTS
%   f  - filter weights
%
% DISCUSSION
%   From the CrIS ATBD and Yong Han.  Currently only implements
%   ccast hires1, 2, and 3 sensor res modes with the new more open
%   NOAA filter passbands.
%

function f = f_atbd(inst)

% select the filter parameters
switch(inst.inst_res)

% case 'lowres' 
%   % original ATBD weights
%   np = [864  528  200];
%   k0 = [ 77   49   22];
%   k1 = [789  481  180];
%   a1 = [ 15   22    8];
%   a2 = [0.5  1.0  2.0];
%   a3 = [ 15   22    8];
%   a4 = [0.5  1.0  2.0];
%
% case 'noaa1' 
%   % noaa old npp high res
%   np = [866  1052   799];
%   k0 = [ 78    95    84];
%   k1 = [790   959   716];
%   a1 = [ 15    44    32];
%   a2 = [0.5   0.5   0.5];
%   a3 = [ 15    44    32];
%   a4 = [0.5   0.5   0.5];

  case 'hires2' 
    % noaa new npp high res
    np = [866  1052   799];
    k0 = [ 78    95    84];
    k1 = [790   959   716];
    a1 = [ 30    59    41];
    a2 = [0.5   0.5   0.5];
    a3 = [ 30    59    41];
    a4 = [0.5   0.5   0.5];

  case 'hires3' 
    % noaa new npp extended res
    np = [874  1052   808];
    k0 = [ 79    95    85];
    k1 = [797   959   724];
    a1 = [ 30    59    41];
    a2 = [0.5   0.5   0.5];
    a3 = [ 30    59    41];
    a4 = [0.5   0.5   0.5];

  case 'hires4' 
    % noaa new j1 extended res
    np = [876  1052   808];
    k0 = [ 79    95    85];
    k1 = [798   959   724];
    a1 = [ 30    59    41];
    a2 = [0.5   0.5   0.5];
    a3 = [ 30    59    41];
    a4 = [0.5   0.5   0.5];

  otherwise
    error(sprintf('unexpected filter type %s', t))
end

% get band index
switch upper(inst.band)
  case 'LW', b = 1;
  case 'MW', b = 2;  
  case 'SW', b = 3;
  otherwise, error('bad band spec');
end

% select table column
np = np(b); k0 = k0(b); k1 = k1(b);
a1 = a1(b); a2 = a2(b); a3 = a3(b); a4 = a4(b);

% channel indices for ATBD spec
k = 1 : inst.npts;

f = (1 ./ (exp(a2.*(k0-a1-k)) + 1)) .* (1 ./ (exp(a4.*(k-k1-a3)) + 1));

