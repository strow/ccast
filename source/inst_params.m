%
% NAME
%   inst_params - set instrument and user-grid parameters
%
% SYNOPSIS
%   [inst, user] = inst_params(band, wlaser, opts)
%
% INPUTS
%   band    - 'LW', 'MW', or 'SW'
%   wlaser  - metrology laser wavelength
%   opts    - optional parameters
% 
% OPTS FIELDS
%   version  - 'snpp' (default), 'jpss1', 'jpss2'
%   resmode  - 'lowres' (default), 'hires1', 'hires2', 'hi2low'
%   addguard - 'false' (default), 'true' to include guard points
%   foax     - focal plane FOV off-axis angles (default not set)
%   frad     - focal plane FOV radii (default not set)
%   a2       - a2 nonlinearity weights (default UW SNPP values)
%
% OUTPUTS
%   inst  - instrument parameters
%   user  - user grid parameters
%
% DISCUSSION
%   The main steps are (1) set default values, (2) allow overrides
%   from opts, (3) set user grid parameters, and (4) set sensor grid
%   parameters.  Focal plane parameters are included in the opts
%   struct for convenience building new SA matrices and are saved
%   with those files
%
% AUTHOR
%   H. Motteler, 4 Oct 2013
%

function [inst, user] = inst_params(band, wlaser, opts)

band = upper(band);

switch band
  case {'LW', 'MW', 'SW'}
  otherwise
    error(['bad band value ', band])
end

%----------
% defaults
%----------
version = 'snpp';
resmode = 'lowres';
addguard = 'false';
foax = [];
frad = [];

% UW SNPP a2 weights (listed in row order)
switch band
  case 'LW'
    a2 = [0.01936  0.01433  0.01609 ...
          0.02192  0.01341  0.01637 ...
          0.01464  0.01732  0.03045];
  case 'MW'
    a2 = [0.00529  0.02156  0.02924  ...
          0.01215  0.01435  0.00372  ...
          0.10702  0.04564  0.00256];
  case 'SW'
    a2 = zeros(1, 9);
end

% process input options
if nargin == 3
  if isfield(opts, 'version'), version = opts.version; end
  if isfield(opts, 'resmode'), resmode = opts.resmode; end
  if isfield(opts, 'addguard'), addguard = opts.addguard; end
  if isfield(opts, 'foax'), foax = opts.foax; end
  if isfield(opts, 'frad'), frad = opts.frad; end
  if isfield(opts, 'a2'), a2 = opts.a2; end
end

switch resmode
  case {'lowres', 'hires1', 'hires2', 'hi2low'}
  otherwise
    error(['bad resmode value ', resmode])
end

%-----------
% user grid
%-----------
switch band
  case 'LW'
    user.v1 = 650;    % first channel
    user.v2 = 1095;   % last channel
    user.opd = 0.8;   % user grid OPD
    user.vr = 15;     % bandpass wings
  case 'MW'  
    user.v1 = 1210;
    user.v2 = 1750;
    user.opd = 0.4;
    user.vr = 20;
  case 'SW'  
    user.v1 = 2155;
    user.v2 = 2550;
    user.opd = 0.2;
    user.vr = 22;
end

% user OPD is 0.8 for high res
switch resmode
  case {'hires1', 'hires2'}, user.opd = 0.8;
end

% derived parameters
user.dv = 1 / (2*user.opd);
user.band = band;

%-------------
% sensor grid
%-------------
switch band
  case 'LW'
    df = 24;       % decimation factor
    npts = 864;    % decimated points
    vbase = 1;     % alias offset

  case 'MW'
    df = 20;
    vbase = 1;
    switch resmode 
      case 'lowres', npts = 528;
      case 'hires1', npts = 1037;
      case {'hires2', 'hi2low'}, npts = 1050;
    end

  case 'SW'
    df = 26;
    vbase = 4;
    switch resmode
      case 'lowres', npts = 200;
      case {'hires1', 'hires2', 'hi2low'}, npts = 797;
    end
end

% option to add guard points
switch addguard
  case 'true', npts = npts + 2;
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

% instrument params
inst.band    = band;
inst.wlaser  = wlaser;
inst.df      = df;
inst.npts    = npts;
inst.vlaser  = vlaser;
inst.dx      = dx;
inst.opd     = opd;
inst.dv      = dv;
inst.cind    = cind;
inst.freq    = freq;
inst.version = version;
inst.resmode = resmode;
inst.addguard = addguard;
inst.foax    = foax(:);
inst.frad    = frad(:);
inst.a2      = a2(:);

% mainly for tests
inst.awidth = awidth;
inst.cutpt  = cutpt;
inst.vdfc   = vdfc;
inst.vbase  = vbase;


