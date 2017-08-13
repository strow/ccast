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
%   should update to use circshift rather than inst.cind
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

% truncate and shift for hi3to2 LW and SW
if strcmp(inst.inst_res, 'hi3to2') && ~strcmp(band, 'MW')
  igm = igm((1:npts)+4, :, :, :);
end

% truncate and apodize for hi3odd res mode
if strcmp(inst.inst_res, 'hi3odd')
  igm = igm(2:npts+1, :, :, :);
  igm = igm_apod(igm, 7);
end

% apodize all IGMs for hires3 res mode
if strcmp(inst.inst_res, 'hires3')
  igm = igm_apod(igm, 7);
end

% do an FFT of shifted data.
spec = fft(fftshift(igm, 1));

% permute the spectra to match the frequency scale
spec = spec(cind, :, :, :);

