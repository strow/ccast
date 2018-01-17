%
% NAME
%   mkSAinv - make an inverse SA matrix
%
% SYNOPSIS
%   function mkSAinv(band, wlaser, sfile, opts)
%
% INPUTS
%   band    - band string, 'LW', 'MW', or 'SW'
%   wlaser  - list of wlaser tabulation points
%   sfile   - filename for the inverse SA matrix
%   opts    - options for inst_params and newILS
%
% OUTPUT
%   a mat file sfile containing 
%     SAinv  - nchan x nchan x 9 inverse SA matrix
%     inst   - inst params struct used to build SAinv
%
% DISCUSSION
%   wlaser should be in the middle of the typical range for a given
%   band, but is not critical
%

function mkSAinv(band, wlaser, sfile, opts)

band = upper(band);

% get interferometric parameters
inst = inst_params(band, wlaser, opts);

% initialize the ILS tabulation
SAinv = zeros(inst.npts, inst.npts, 9);

% loop on FOVs
for j = 1 : 9

  % loop on channels
  for i = 1 : inst.npts
  
    % call newILS
    SAinv(:, i, j) = newILS(j, inst, inst.freq(i), inst.freq, opts);

  end

  % invert the SA matrix for this FOV
  SAinv(:, :, j) = inv(squeeze(SAinv(:, :, j)));

  fprintf(1, '.')
end
fprintf(1, '\n')

% save the SA inverse
save(sfile, 'SAinv', 'inst', 'opts');

