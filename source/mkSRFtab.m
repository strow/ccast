%
% NAME
%   mkSRFtab -  build SRF matrix tables for interpolation
%
% SYNOPSIS
%   function mkSRFtab(band, wlist, sfile, opts)
%
% INPUTS
%   band   - band string, 'LW', 'MW', or 'SW'
%   wlist  - list of wlaser tabulation points
%   sfile  - output file for SRF matrix tables 
%   opts   - options for inst_params
%
% OUTPUT
%   mat file containing a structure array "s" with fields
%     s().stab    - tabulated SRF matrices
%     s().vobs    - corresponding frequency scales
%     s().wlaser  - corresponding wlaser values
%   and the "inst" struct from the last wlaser value
%
% NOTES
%   works with with getSRFwl, derived from mkSRFwl, modified to work
%   with newILS with no band-edge extension
%

function mkSRFtab(band, wlist, sfile, opts)

band = upper(band);
wlist = sort(wlist(:));

% ------------------
% default parameters
% ------------------

% initialize output struct
s = struct([]);

% pass opts to inst_params
if nargin < 4
  opts = struct;
end

% ----------------------
% loop on wlaser values
% ----------------------

for wi = 1 : length(wlist)

  % calculate interferometric parameters
  inst = inst_params(band, wlist(wi), opts);

  % initialize the ILS tabulation
  smat = zeros(inst.npts, inst.npts, 9);

  % loop on channels
  for i = 1 : inst.npts
  
    % loop on FOVs
    for j = 1 : 9

      % call newILS
      smat(:, i, j) = newILS(j, inst, inst.freq(i), inst.freq, 2000);

    end
    fprintf(1,'.');
  end
  fprintf(1,'\n');

  % save output fields
  s(wi).stab = smat;
  s(wi).vobs = inst.freq;
  s(wi).wlaser = wlist(wi);

end

% save the output struct
save(sfile, 's', 'inst');

