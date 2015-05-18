%
% NAME
%   mkSAinv - make an inverse extended SA matrix
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

% extend the frequency grid
k = round(inst.npts * 0.2);
sv1 = inst.freq(1) - k * inst.dv;
snpts = inst.npts + 2 * k;
sfreq = sv1 + (0 : snpts - 1)' * inst.dv;
sind = k + 1 : k + inst.npts;
SAfwd = zeros(snpts, snpts, 9);

% isequal(sfreq(k+1), inst.freq(1))
% isclose(sfreq(k+inst.npts), inst.freq(inst.npts))
% isclose(inst.freq, sfreq(sind))

% initialize the ILS tabulation
SAinv = zeros(inst.npts, inst.npts, 9);

% loop on FOVs
for j = 1 : 9

  % loop on channels
  for i = 1 : snpts
  
    % call newILS
    SAfwd(:, i, j) = newILS(j, inst, sfreq(i), sfreq, opts);
  end

  % invert the SA matrix for this FOV
  SAtmp = inv(squeeze(SAfwd(:,:,j)));
  SAinv(:, :, j) = SAtmp(sind, sind);

  fprintf(1, '%d', j)
end
fprintf(1, '\n')

% save the SA inverse matrix
save(sfile, 'SAinv', 'inst'  );

% save the SA forward matrix
if ~isempty(findstr('inv', sfile))
  sfile = strrep(sfile, 'inv', 'fwd');
else
  sfile = sprintf('SAfwd%s', band);
end
save(sfile, 'SAfwd', 'inst', 'sfreq', 'sind');
