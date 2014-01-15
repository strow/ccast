%
% NAME
%   specNF - spectral space FIR filter at the sensor grid
%
% SYNOPSIS
%   sfilt = specNF(inst, tfile)
%
% INPUTS
%   inst  - instrument params
%   tfile - time domain filter
%
% OUTPUTS
%   sfilt - spectral space filter
%
% DISCUSSION
%   from Dan Mooney's FIR filter demo
%
% AUTHOR
%  H. Motteler, 6 Dec 2013
%

function sfilt = specNF(inst, tfile)

d2 = load(tfile);

switch upper(inst.band)
  case 'LW', filt = d2(:,1) + 1i * d2(:,2);
  case 'MW', filt = d2(:,3) + 1i * d2(:,4);
  case 'SW', filt = d2(:,5) + 1i * d2(:,6);
  otherwise, error(['bad band spec ', inst.band])
end

S = fft(filt, inst.npts * inst.df);
I = ifft(S);
S1 = fft(I(1 : inst.df : inst.npts * inst.df)) * inst.df;
S2 = circshift(S1, [-inst.cutpt, 0]);
sfilt = abs(S2);

