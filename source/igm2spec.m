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

switch inst.inst_res
  case {'hires3', 'hires4'}  % apodize extended res modes
    igm = igm_apod(igm, 7);

% case 'hi3odd'  % truncate and apodize
%   igm = igm(2:npts+1, :, :, :);
%   igm = igm_apod(igm, 7);
%
% case 'hi3to2'  % truncate and shift LW and SW
%   if ~strcmp(band, 'MW')
%     igm = igm((1:npts)+4, :, :, :);
%   end
end

% do an FFT of shifted data.
spec = fft(fftshift(igm, 1));

% permute the spectra to match the frequency scale
spec = spec(cind, :, :, :);

