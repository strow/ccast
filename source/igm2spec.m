%
% NAME
%   igm2spec - take interferograms to uncalibrated spectra
%
% SYNOPSIS
%   spec = igm2spec(igm, inst);
%
% INPUTS
%   igm   - nchan x 9 x 34 x nscan interferograms
%   inst  - instrument interferometric specs
% 
% OUTPUTS
%   spec  - nchan x 9 x 34 x nscan count spectra
%
% DISCUSSION
%   the input array actually has nchan+2 points in the first
%   dimension, but the first and last are "guard points" and 
%   are dropped
%
%   could be updated to use matlab fftshift w/ proper dimension
%   parameter
%
% AUTHOR
%   H. Motteler, 10 Apr 2012
%

function spec = igm2spec(igm, inst)

band = upper(inst.band);

% get number of scans
[m,n,k,nscan] = size(igm);

% instrument params
npts = inst.npts;
cind = inst.cind;

% tind mimics fftshift for odd-sized point sets
tind = [ceil(npts/2)+1 : npts, 1 : ceil(npts/2)]';

% initialize the output array
spec = zeros(npts, 9, 34, nscan);

% drop the guard points before the FFT
itmp = igm(2:npts+1, :, :, :);

% do an FFT of shifted data.
stmp = fft(itmp(tind, :, :, :));

% permute the spectra to match the frequency scale
spec = stmp(cind, :, :, :);

