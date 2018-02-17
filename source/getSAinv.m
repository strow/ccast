%
% NAME
%   getSAinv - load an SA inverse matrix
%
% SYNOPSIS
%   function [SAinv, inst2] = getSAinv(inst1, opts)
%
% INPUTS
%   inst1  - current active inst params struct
%   opts   - opts struct, for the SA inv file
%
% OUTPUTS
%   SAinv  - nchan x nchan x 9 inverse SA matrix
%   inst2  - inst params struct used to build SAinv
%

function [SAinv, inst2] = getSAinv(inst1, opts)

% get sfile from the opts struct
switch inst1.band
  case 'LW', sfile = opts.LW_sfile;
  case 'MW', sfile = opts.MW_sfile;
  case 'SW', sfile = opts.SW_sfile;
  otherwise, error(['bad band spec ', inst1.band]);
end

% load the SA inverse file, get SAinv and inst
load(sfile);
inst2 = inst;

% some sanity checks
if ~strcmp(upper(inst1.band), upper(inst2.band))
  error('bands do not match')
elseif ~isequal(inst1.npts, inst2.npts)
  error('sensor grid sizes not match')
end

