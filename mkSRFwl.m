%
% NAME
%   mkSRFwl -  build SRF matrix tables for interpolation
%
% SYNOPSIS
%   function mkSRFwl(bstr, wlist, ffile, sfile)
%
% INPUTS
%   bstr    - band string, 'LW', 'MW', or 'SW'
%   wlist   - list of wlaser tabulation points
%   ffile   - focal plane input file 
%   sfile   - output file for SRF matrix tables 
%
% OUTPUT
%   a mat file containing a structure array "s" with fields
%     s().stab    - tabulated SRF matrices
%     s().vobs    - corresponding frequency scales
%     s().wlaser  - corresponding wlaser values
%   and a structure "f" with the focal plane parameters
%
% NOTES
%   need to check that wlist is in sorted order
%

function mkSRFwl(bstr, wlist, ffile, sfile)

% ------------------
% default parameters
% ------------------

% extended band edges for SRF normalization
efrq = 20;

% oaffov fixed parameters
nslice = 2001;

% default FOV off-axis angles
foax = [ 
   0.027150951288746
   0.019198621771938
   0.027150951288746
   0.019198621771938
                   0
   0.019198621771938
   0.027150951288746
   0.019198621771938
   0.027150951288746 ];

% default FOV radius
frad = ones(9,1) * 0.008403361344538;

% FOV deltas
doax = zeros(9,1);  % off-axis difference from foax
drad = zeros(9,1);  % radius difference from frad

% load a specified focal plane file
if ~isempty(ffile)
  load(ffile, 'foax', 'frad')
end

% initialize output struct
s = struct([]);

% ----------------------
% loop on wlaser values
% ----------------------

for wi = 1 : length(wlist)

  % call readspec3() to calculate interferometric parameters
  opt1.nospec = 1;
  opt1.wlaser = wlist(wi);
  [stmp, vobs, opt2] = readspecX('nofile', bstr, opt1);
  dv     = opt2.dv;
  vlaser = opt2.vlaser;
  npts   = opt2.npts;
  opd    = opt2.mpd;

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
      thetac = foax(j) + doax(j);
      hfov = frad(j) + drad(j);

      % call oaffov2
      [oafreq,oasrf] = oaffov2(v1,fchan,opd,thetac,hfov,nslice);
      % [oasrf,t1,t2] = computeIls(v1,fchan,opd,thetac,hfov);

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

% save focal plane parameters
f.foax = foax;
f.frad = frad;
f.doax = doax;
f.drad = drad;

% save the output struct
save(sfile, 's', 'f');

