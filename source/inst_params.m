%
% NAME
%   inst_params - set sensor and user-grid parameters
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
%   inst_res - 'lowres' (default), 'hires1-3', 'hi3to2'
%   user_res - 'lowres' (default), 'hires'
%   foax     - focal plane FOV off-axis angles (default not set)
%   frad     - focal plane FOV radii (default not set)
%   a2       - a2 nonlinearity weights (default UW SNPP values)
%   pL, pH   - processing filter passband start and end freqs
%   rL, rH   - processing filter out-of-band LHS and RHS rolloff
%
% OUTPUTS
%   inst  - instrument parameters
%   user  - user grid parameters
%
% DISCUSSION
%   The main steps are (1) set default values, (2) allow overrides
%   from opts, (3) set user grid parameters, and (4) set sensor grid
%   parameters.  Focal plane parameters can be set in the opts struct 
%   for convenience building new SA matrices, and are saved in those
%   files
%
%   sensor grid resolution modes (inst_res values)
%               LW    MW   SW
%     lowres  - 866,  530, 202
%     hires1  - 866, 1039, 799
%     hires2  - 866, 1052, 799
%     hi3to2  - 866, 1052, 800
%     hires3  - 874, 1052, 808
%
%   user grid resolution modes (user_res values)
%     lowres  - opd 0.8 LW, 0.4 MW, 0.2 SW
%     hires   - opd 0.8 all bands
%
%  DEPRECATED OPTIONS AND FIELDS
%    resmode 'lowres', 'hires2', and 'hi2low' work as before
%    usr.vr is used for bandpass filtering by some non-ccast app's
%
% AUTHOR
%   H. Motteler, 4 Oct 2013
%

function [inst, user] = inst_params(band, wlaser, opts)

% keep "band" upper-case locally
band = upper(band);

%----------
% defaults
%----------
version = 'snpp';
inst_res = 'lowres';
user_res = 'lowres';
foax = [];
frad = [];

% UW SNPP a2 weights
switch band
  case 'LW'
    a2 = [0.0194 0.0143 0.0161 0.0219 0.0134 0.0164 0.0146 0.0173 0.0305];
  case 'MW'
    a2 = [0.0053 0.0216 0.0292 0.0121 0.0143 0.0037 0.1070 0.0456 0.0026];
  case 'SW'
    a2 = zeros(1, 9);
  otherwise
    error(['bad band value ', band])
end

% e5-e6 cal algo filters
switch band
  case 'LW', pL =  650; pH = 1100; rL = 15; rH = 20; vr = 15;
  case 'MW', pL = 1200; pH = 1760; rL = 30; rH = 30; vr = 20;
  case 'SW', pL = 2145; pH = 2560; rL = 30; rH = 30; vr = 22;
end

% allow some old "resmode" style options
if nargin == 3 && isfield(opts, 'resmode') 
  switch opts.resmode
    case 'hires2', inst_res = 'hires2'; user_res = 'hires';
    case 'hi2low', inst_res = 'hires2'; user_res = 'lowres';
    case 'lowres', inst_res = 'lowres'; user_res = 'lowres';
  end
end

% apply any "opts" input options
if nargin == 3
  if isfield(opts, 'version'), version = opts.version; end
  if isfield(opts, 'inst_res'), inst_res = opts.inst_res; end
  if isfield(opts, 'user_res'), user_res = opts.user_res; end
  if isfield(opts, 'foax'), foax = opts.foax; end
  if isfield(opts, 'frad'), frad = opts.frad; end
  if isfield(opts, 'a2'), a2 = opts.a2; end
  if isfield(opts, 'pL'), pL = opts.pL; end
  if isfield(opts, 'pH'), pH = opts.pH; end
  if isfield(opts, 'rL'), pL = opts.rL; end
  if isfield(opts, 'rH'), pH = opts.rH; end
end

%-----------
% user grid
%-----------
switch band
  case 'LW'
    user.v1 = 650;    % first channel
    user.v2 = 1095;   % last channel
    user.opd = 0.8;   % user grid OPD

  case 'MW'  
    user.v1 = 1210;
    user.v2 = 1750;
    user.opd = 0.4;

  case 'SW'  
    user.v1 = 2155;
    user.v2 = 2550;
    user.opd = 0.2;
end

% user OPD is 0.8 for high res
switch user_res
  case 'lowres'
  case 'hires', user.opd = 0.8;
  otherwise, error(['bad user res value ', user_res])
end

% derived parameters
user.dv = 1 / (2*user.opd);
user.band = band;
user.vr = vr;

%-------------
% sensor grid
%-------------
switch band
  case 'LW'
    df = 24;          % decimation factor
    vbase = 1;        % alias offset
    switch inst_res   % interferogram size
      case {'lowres', 'hires1', 'hires2', 'hi3to2'}, npts = 866;
      case 'hires3', npts = 874;
    end

  case 'MW'
    df = 20;
    vbase = 1;
    switch inst_res
      case 'lowres', npts = 530;
      case 'hires1', npts = 1039;
      case {'hires2', 'hires3', 'hi3to2'}, npts = 1052;
    end

  case 'SW'
    df = 26;
    vbase = 4;
    switch inst_res
      case 'lowres', npts = 202;
      case {'hires1', 'hires2'}, npts = 799;
      case 'hi3to2', npts = 800;
      case 'hires3', npts = 808;
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
inst.inst_res = inst_res;
inst.user_res = user_res;
inst.foax    = foax(:);
inst.frad    = frad(:);
inst.a2      = a2(:);
inst.pL      = pL;
inst.pH      = pH;
inst.rL      = rL;
inst.rH      = rH;

% mainly for tests
inst.awidth = awidth;
inst.cutpt  = cutpt;
inst.vdfc   = vdfc;
inst.vbase  = vbase;


