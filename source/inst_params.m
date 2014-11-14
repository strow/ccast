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
%   resmode  - 'lowres', 'hires1', or 'hires2'
%   foax     - focal plane off axis angles
%   frad     - focal plane radii
%   
% OUTPUTS
%   inst  - instrument parameters
%   user  - user grid parameters
%
% DISCUSSION
%   Defaults are low res mode and the LLS v33a focal plane.
%
%   Note there are some very slightly different versions of v33a
%   around.  The values below are from LLS, Feb or Mar 2012, and
%   agree with the dg_v33a_lw.mat also circulated from around that
%   time to roughly single precision accuracy, 10e-5 or better.
%   The values are tabulated in column order, not as the focal 
%   plane is viewed
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

% default res mode
resmode = 'lowres';

% default off-axis angles from LLS v33a focal plane
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

% default FOV radius from LLS v33a focal plane
frad = 0.008403 * ones(9,1);

% process input options
if nargin == 3
  if isfield(opts, 'frad'), frad = opts.frad; end
  if isfield(opts, 'foax'), foax = opts.foax; end
  if isfield(opts, 'resmode'), resmode = opts.resmode; end
end

switch resmode
  case {'lowres', 'hires1', 'hires2'}
  otherwise
    error(['bad opt.resmode value ', resmode])
end

%------------
%  user grid
%------------
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

% ---------------
% instrument grid
% ---------------
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
      case 'hires2', npts = 1050;
    end

  case 'SW'
    df = 26;
    vbase = 4;
    switch resmode
      case 'lowres', npts = 200;
      case 'hires1', npts = 797;
      case 'hires2', npts = 797;
    end
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

% mainly for tests
inst.awidth = awidth;
inst.cutpt  = cutpt;
inst.vdfc   = vdfc;
inst.vbase  = vbase;

% focal plane params 
inst.foax = foax(:);
inst.frad = frad(:);

