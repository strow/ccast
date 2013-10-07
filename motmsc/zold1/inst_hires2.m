%
% NAME
%   inst_hires2 - get instrument interferometric parameters
%
% SYNOPSIS
%   [inst, user] = inst_hires2(band, wlaser)
%
% INPUTS
%   band    - 'LW', 'MW', or 'SW'
%   wlaser  - metrology laser wavelength
% 
% OUTPUTS
%   inst  - instrument parameters
%   user  - user grid parameters
%
% DISCUSSION
%   high-res version 2
%
%   set instrument (aka sensor grid) parameters as a function of
%   wlaser and locally assigned values, and the user grid to spec
%
% AUTHOR
%   H. Motteler, 10 Apr 2012
%

function [inst, user] = inst_hires2(band, wlaser)

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
    vbase = 1;     % alias offset

  case 'MW'
    df = 20;       % decimation factor
    npts = 1050;   % hi res decimated points
    vbase = 1;     % alias offset

  case 'SW'
    df = 26;       % decimation factor
    npts = 797;    % hi res decimated points
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
vmid = (user.v1 + user.v2) / 2;     % desired band center (d37)
vdfc = vmid - awidth / 2;           % desired 1st chan cent (d38)
cutpt = mod(round(vdfc/dv), npts);  % cut point (d9)

% get the channel index permutation
cind = [(cutpt+1:npts)' ; (1:cutpt)'];
freq = dv * (cutpt:cutpt+npts-1)' + awidth * vbase;

% return selected parameters 
inst.wlaser = wlaser;
inst.df     = df;
inst.npts   = npts;
inst.vlaser = vlaser;
inst.dx     = dx;
inst.opd    = opd;
inst.dv     = dv;
inst.cind   = cind;
inst.freq   = freq;
inst.band   = band;
inst.awidth = awidth;
inst.cutpt  = cutpt;
inst.vdfc   = vdfc;
inst.vbase  = vbase;

