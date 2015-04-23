%
% NAME
%   getSAinv  -  load an SA inverse matrix
%
% SYNOPSIS
%   function [SAinv, inst2] = getSAinv(sfile, inst1)
%
% INPUTS
%   sfile  - mat file for SA inverse matrix
%   inst1  - optional current inst params struct
%
% OUTPUTS
%   SAinv  - nchan x nchan x 9 inverse SA matrix
%   inst   - inst params struct used to build SAinv
%

function [SAinv, inst2] = getSAinv(sfile, inst1)

% load the SA inverse file, get SAinv and inst
load(sfile);
inst2 = inst;

% a few sanity checks
if nargin == 2
  if ~strcmp(upper(inst1.band), upper(inst2.band))
    error('bands do not match')
  elseif ~strcmp(inst1.resmode, inst2.resmode)
    error('res modes do not match')
  elseif ~isequal(inst1.npts, inst2.npts)
    error('sensor grid sizes not match')
  end
end

