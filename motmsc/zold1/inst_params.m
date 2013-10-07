%
% NAME
%   inst_params - set selected instrument parameters
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
%   resmode  - currently 'lowres', 'hires1', or 'hires2'
%   foax     - focal plane off axis angles
%   frad     - focal plane radii
%   
% OUTPUTS
%   inst  - instrument parameters
%   user  - user grid parameters
%
% DISCUSSION
%   wrapper for inst_lowres.m, inst_hires1.m, and inst_hires2.m
%   defaults are low res and the focal plane as tabulated below
%
% AUTHOR
%   H. Motteler, 22 Sep 2013
%

function [inst, user] = inst_params(band, wlaser, opts)

%------------------
% default res mode
%------------------
resmode = 'lowres';

%----------------------
%  default focal plane
%----------------------
% FOV off-axis angles based on LLS Feb 13 data
switch upper(band)
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
  otherwise
    error(['bad value for band ', band]);
end

% single value for FOV radius
frad = 0.008403 * ones(9,1);

%-----------------------
% process input options
%-----------------------
if nargin == 3
  optvar = fieldnames(opts);
  for i = 1 : length(optvar)
    vname = optvar{i};
    if exist(vname, 'var')
      eval(sprintf('%s = opts.%s;', vname, vname));
    end
  end
end

%---------------------------------------
% call the selected instrument function
%---------------------------------------
switch lower(resmode)
  case 'lowres', [inst, user] = inst_lowres(band, wlaser);
  case 'hires1', [inst, user] = inst_hires1(band, wlaser);
  case 'hires2', [inst, user] = inst_hires2(band, wlaser);
  otherwise, error(['bad value for resmode ', resmode]);
end

%--------------------------------------
% add focal plane params to the output
%--------------------------------------
inst.foax = foax(:);
inst.frad = frad(:);

