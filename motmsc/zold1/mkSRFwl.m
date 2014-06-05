%
% NAME
%   mkSRFwl -  build SRF matrix tables for interpolation
%
% SYNOPSIS
%   function mkSRFwl(band, wlist, sfile, opts)
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
%   paired with getSRFwl
%
%   derived from FM2008/mkSRFwl, modified to use instrument specs
%   struct and dropped default focal plane values
%
%   works with either oaffov2 or computeIls
%

function mkSRFwl(band, wlist, sfile, opts)

band = upper(band);
wlist = sort(wlist(:));

% ------------------
% default parameters
% ------------------

% extended band edges for SRF normalization
efrq = 20;

% oaffov fixed parameters
nslice = 2001;

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
  dv   = inst.dv;
  npts = inst.npts;
  opd  = inst.opd;
  vobs = inst.freq;
  foax = inst.foax;
  frad = inst.frad;

  % extra points for the band edges
  epts = floor(efrq / dv);

  % extended band edges for oaffov
  emin = vobs(1) - epts * dv;
  emax = vobs(npts) + epts * dv;

  % build oaffov grid
  v1 = 0 : npts + 2*epts - 1;
  v1 = (v1 * dv) + emin;
  v1 = v1(:);

  % iobs takes oaffov grid v1 to vobs grid
  imin = epts + 1;
  imax = epts + npts;
  iobs = imin : imax;

  % *** temporary sanity check ***
  % rms(vobs - v1(iobs))

  % initialize the SRF matrix for this wlaser value
  smat = zeros(npts, npts, 9);

  % loop on channels
  for i = 1 : npts
  
    % set oaffov channel freq
    fchan  = vobs(i);

    % loop on FOVs
    for j = 1 : 9

      % FOV dependent oaffov params
      thetac = foax(j);
      hfov = frad(j);

      % call oaffov2
      [oafreq, oasrf] = oaffov2(v1, fchan, opd, thetac, hfov, nslice);
      % [oafreq, oasrf] = oaffov_p(v1, fchan, opd, thetac, hfov, nslice, npts);
      % [oasrf, t1, t2] = computeIls(v1, fchan, opd, thetac, hfov);

      % save convolutions in column order
      smat(:, i, j) = oasrf(iobs);

    end
    fprintf(1,'.');
  end
  fprintf(1,'\n');

  % save output fields
  s(wi).stab = smat;
  s(wi).vobs = vobs;
  s(wi).wlaser = wlist(wi);

end

% save the output struct
save(sfile, 's', 'inst');

