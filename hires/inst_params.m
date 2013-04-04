%
% NAME
%   inst_params - set selected instrument parameters
%
% SYNOPSIS
%   [inst, user] = inst_params(band, wlaser, opts)
%
% INPUTS
%   band  - 'LW', 'MW', or 'SW'
%   opts  - optional parameters
% 
% OUTPUTS
%   inst  - instrument parameters
%   user  - user grid parameters
%
% DISCUSSION
%
%   derived from readspec6/X and focal plane specs from the ccast
%   function spectral_params.m, merge with the latter as needed
%
%   sets instrument aka sensor grid parameters as a function of
%   wlaser and locally assigned values.  the user grid here is just
%   an interpolation target and can be any frequency grid spanned 
%   by the sensor grid
%
%   for now opts is just a place holder, it might be used to pass
%   in parameter overrides
%
%   a major limitation with this setup is it doesn't allow for easy
%   swapping of params sets
%
% AUTHOR
%   H. Motteler, 10 Apr 2012
%

function [inst, user] = inst_params(band, wlaser, opts)

band = upper(band);

% -----------
%  user grid
% -----------

switch band
  case 'LW'
    user.v1 = 650;
    user.v2 = 1095;
    user.opd = 0.8;
    user.vr = 20;
  case 'MW'  
    user.v1 = 1210;
    user.v2 = 1750;
    user.opd = 0.8;
    user.vr = 20;
  case 'SW'  
    user.v1 = 2155;
    user.v2 = 2550;
    user.opd = 0.8;
    user.vr = 22;
end

user.dv = 1 / (2*user.opd);
user.band = band;

% ---------------
% instrument grid
% ---------------

% assigned parameters
switch band
  case 'LW'
    df = 24;       % decimation factor
    npts = 864;    % number of decimated points
    c1ind = 106;   % first channel index
    vbase = 1;     % alias offset

  case 'MW'
    df = 20;       % decimation factor
%   npts = 528;    % number of decimated points
%   c1ind = 420;   % first channel index
    npts = 1037;   % hi res decimated points
    c1ind = 824;   % hi res first channel index
    vbase = 1;     % alias offset

  case 'SW'
    df = 26;       % decimation factor
%   npts = 200;    % number of decimated points
%   c1ind = 48;    % first channel index
    npts = 797;    % hi res decimated points
    c1ind = 192;   % hi res first channel index
    vbase = 4;     % alias offset

  otherwise
     error(sprintf('bad band parameter %s', band))
end

% derived parameters
vlaser = 1e7 / wlaser;  % laser frequency
dx  = df / vlaser;      % distance step
opd = dx * npts / 2;    % max OPD
dv  = 1 / (2*opd);      % frequency step
awidth = vlaser / df;   % alias width

% get the channel index permutation
cind = [(c1ind+1:npts)' ; (1:c1ind)'];
freq = dv * (c1ind:c1ind+npts-1)' + awidth * vbase;

% return selected parameters 
inst.wlaser = wlaser;
inst.npts   = npts;
inst.vlaser = vlaser;
inst.dx     = dx;
inst.opd    = opd;
inst.dv     = dv;
inst.cind   = cind;
inst.freq   = freq;
inst.band   = band;

% -------------
%  focal plane
% -------------

% FOV off-axis angles based on LLS Feb 13 data
switch band
  case 'LW'
    foax = [0.02688708 0.01931040 0.02745719 ...
            0.01872599 0.00039304 0.01946177 ...
            0.02669410 0.01898521 0.02720102];
  case 'MW'  
    foax = [0.02692817  0.01932544  0.02744433 ...
            0.01877022  0.00041968  0.01943880 ...
            0.02670933  0.01897094  0.02714583];
  case 'SW'  
    foax = [0.02687735  0.01928389  0.02737835 ...
            0.01875077  0.00034464  0.01935134 ...
            0.02671876  0.01895481  0.02709675];
end

% return values in column order
inst.foax = foax(:);

% single value for FOV radius
inst.frad = 0.008403 * ones(9,1);

