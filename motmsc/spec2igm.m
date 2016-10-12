%
% NAME
%   spec2igm - take uncalibrated spectra to interferograms
%
% SYNOPSIS
%   igm = spec2igm(spec, inst);
%
% INPUTS
%   spec  - nchan x 9 x 34 x nscan count spectra
%   inst  - instrument interferometric specs
% 
% OUTPUTS
%   igm   - nchan x 9 x 34 x nscan interferograms
%
% DISCUSSION
%   inverse of igm2spec
%
% AUTHOR
%   H. Motteler, 24 Sep 2016
%

function igm = spec2igm(spec, inst)

band = upper(inst.band);

% instrument params
npts = inst.npts;

% undo the cutpoint shift
spec = circshift(spec, inst.cutpt);

% undo the FFT
igm = fftshift(ifft(spec), 1); 

