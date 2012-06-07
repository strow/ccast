%
% NAME
%   finterp2 - fourier interpolation, wrapper for interpft
%
% SYNOPSIS
%   function [rad2, frq2] = finterp(rad1, frq1, sfac, roff);
%
% INPUTS
%   rad1 - nchan1 x nobs radiance array
%   frq1 - nchan1 corresponding frequencies
%   sfac - scale factor (integer, greater than 1)
%   roff - optional rolloff at band edges
%
% OUTPUTS
%   rad2 - nchan2 x nobs output radiance vector
%   frq2 - nchan2 corresponding frequencies
%
% NOTES
%   finterp2 is a wrapper for the matlab interpft that adds an
%   output frequency scale and optional rolloff at band edges
%
%   The output frequency grid has sfac times the number of points
%   in the input grid, that is,  nchan2 = nchan1 * sfac, with the
%   ouptput frequency spacing dv2 = dv1/sfac.
%
%   Setting roff = k rolls off band edges k units from the ends.
%
% AUTHOR
%   H. Motteler, 8 Mar 08

function [rad2, frq2] = finterp(rad1, frq1, sfac, roff);

% make frq1 a column vector
frq1 = frq1(:);

% rad1 channel spacing
dv1 = frq1(2) - frq1(1);

% check that input args conform
[nchan1,nobs] = size(rad1);
if nchan1 ~= length(frq1)
  error('rad1 rows must match frq1 length')
end

% optional frequency domain filter at band edges
if nargin == 4
  rpts = round(roff / dv1);  % rolloff points
  f0 = (1+cos(pi+(0:rpts-1)*pi/(rpts)))/2;
  filt = [f0, ones(1,nchan1-2*rpts), fliplr(f0)]';
  for i = 1 : nobs
    rad1(:,i) = rad1(:,i) .* filt;
  end
end

% call interpft for the interpolation
nchan2 = sfac * nchan1;
rad2 = interpft(rad1, nchan2);

% set the output frequency scale
dv2 = dv1 / sfac;
frq2 = frq1(1) + dv2 * (0 : nchan2 - 1);


