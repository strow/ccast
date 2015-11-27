%
% NAME
%   igm_apod -- cosine apodization of interferogram wings
%
% SYNOPSIS
%   igm2 = igm_apod(igm1, r)
%
% INPUTS
%   igm1  - input interferogram
%   r     - apodize r - 1 points
%   
% OUTPUTS
%   igm2  - apodized interferogram
%
% AUTHOR
%  H. Motteler, 26 Nov 2015

function igm2 = igm_apod(igm1, r)

[m,n,k,nscan] = size(igm1);

% values for test plot
% m = 20; r = 7;

wL = (cos(pi * (1 + (1:(r-1))/r)) + 1)/2;
wR = (cos(pi * (1:(r-1))/r) + 1)/2;

apod = ones(m, 1);
apod(1:(r-1)) = wL;
apod(m-(r-2):m) = wR;

% test plot
% plot(1:m, apod)

apod = apod * ones(1, n*k*nscan);
apod = reshape(apod, m, n, k, nscan);

igm2 = igm1 .* apod;

