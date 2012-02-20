%
% NAME
%   readspec6 - get spectra from a CrIS RDR interferogram
%
% SYNOPSIS
%   [spec, freq, opts] = readspec6(igm, band, opts);
%
% INPUTS
%   igm   - matlab IGM struct
%   band  - 'LW', 'MW', or 'SW'
%   opts  - optional parameters
% 
% OUTPUTS
%   spec  - nchan x nsamp x 9 radiance data
%   freq  - nchan x 1 frequency grid 
%   opts  - input opts plus some internal data
%
% DISCUSSION
%
%   Most of the interferometric parameters are functions of wlaser.
%   A default value s set here but it can be overridden by passing
%   in wlaser as a field of the opts parameter.
%
%   Note that the spectra returned does not depend on wlaser, but
%   the frequency scale and other values returned do.  readspec6
%   can be called with nospec=1 to recalculate just those values.
%
%   This version is totally vectorized, the loop on FOVs is gone 
%   and the shapes of the input igm and output spec now agree.
%
% AUTHOR
%   H. Motteler, 28 Sep 2011
%

function [spec, freq, opts] = readspec6(igm, band, opts)

% default general parameters
badfov=[];      % all FOVs OK
nospec = 0;     % return a spectra

% default interferometric params
wlaser = 775.0;   % nominal laser wavelength

% band 1 params
b1.df = 24;	  % decimation factor
b1.npts = 864;    % number of decimated points
b1.c1ind = 106;   % first channel index
b1.vhack = 1;

% band 2 params
b2.df = 20;	  % decimation factor
b2.npts = 528;    % number of decimated points
b2.c1ind = 420;   % first channel index
b2.vhack = 1;

% band 3 params
b3.df = 26;	  % decimation factor
b3.npts = 200;    % number of decimated points
b3.c1ind = 48;    % first channel index
b3.vhack = 4;

% option to override defaults with gopts fields
if nargin == 3
  optvar = fieldnames(opts);
  for i = 1 : length(optvar)
    vname = optvar{i};
    if exist(vname, 'var')
      % fprintf(1, 'readspec6: setting %s\n', vname)
      eval(sprintf('%s = opts.%s;', vname, vname));
    else
      fprintf(1, 'readspec6: unknown option variable %s\n', vname);
    end
  end
end

% select interferometric parameters by band name
switch band
  case 'LW'
     df = b1.df; npts = b1.npts; c1ind = b1.c1ind; vhack = b1.vhack;
  case 'MW'
     df = b2.df; npts = b2.npts; c1ind = b2.c1ind; vhack = b2.vhack;
  case 'SW'
     df = b3.df; npts = b3.npts; c1ind = b3.c1ind; vhack = b3.vhack;
  otherwise
     error(sprintf('bad band parameter %s', band))
end

% get the remaining interferometric parameters
% note awidth = dv*npts, and for band 1, mpd = wlaser*20736/2e7
vlaser = 1e7/wlaser;	% laser frequency
awidth = vlaser / df;	% alias width
dx = df / vlaser;	% distance step
mpd = dx * npts / 2;	% max OPD
dv = 1 / (2*mpd);	% frequency step

% get the channel index permutation
cind = [(c1ind+1:npts)' ; (1:c1ind)'];
freq = dv * (c1ind:c1ind+npts-1)' + awidth * vhack;

% return interferometric parameters in opts
opts.npts   = npts;
opts.vlaser = vlaser;
opts.awidth = awidth;
opts.dx     = dx;
opts.mpd    = mpd;
opts.dv     = dv;
opts.cind   = cind;

% option to skip the igm processing and spectral transform and 
% just return the interferometric parameters and frequency scale 
if nospec
  spec = [];
  return
end

[m,n,nifg] = size(igm);

% use tind in place of the built-in fftshift, as we don't want 
% a  true 2D fft shift, just a shift of all columns in an array
tind = [npts/2+1 : npts, 1 : npts/2]';

% initialize the output array
spec = zeros(npts, 9, nifg);

% drop the guard points before the FFT
itmp = igm(2:npts+1, :, :);  % this looks best
% itmp = igm(1:npts, :, :);    % used for tvac tests
% itmp = igm(3:npts+2, :, :);  % sign change towards center

% do an FFT of shifted data.
stmp = fft(itmp(tind, :, :));

% permute the spectra to match the frequency scale
spec = stmp(cind, :, :);

