%
% NAME
%   gauss_filt - 7-point Gaussian FIR filter
%
% SYNOPSIS
%   r2 = gauss_filt(r1)
%
% INPUT
%   r1  -  m x n column-order input data
%   
% OUTPUT
%   r2  -  m x n column-order smoothed data
%
% DISCUSSION
%   a 7-point Gaussian is created such that each discrete step away
%   from the center is one standard deviation, with the endpoints 3
%   standard deviations from the center.  This is used to generate a
%   sparse banded matrix that is applied to the columns of input r1.
%
% AUTHOR
%  H. Motteler, 15 Feb 2015
%

function r2 = gauss_filt(r1)

% calculate the gaussian
x = [0 1 2 3];
w =  exp(-x.^2 / 2) / sqrt(2*pi);

% build the sparse matrix
[n, k] = size(r1);
d0r = 1 : n;        d0c = 1 : n;    v0 = ones(1,n) * w(1);
d1r = 1 : n - 1;    d1c = 2 : n;    v1 = ones(1,n-1) * w(2);
d2r = 1 : n - 2;    d2c = 3 : n;    v2 = ones(1,n-2) * w(3);
d3r = 1 : n - 3;    d3c = 4 : n;    v3 = ones(1,n-3) * w(4);

irow = [d0r, d1r, d2r, d3r, d1c, d2c, d3c];
icol = [d0c, d1c, d2c, d3c, d1r, d2r, d3r];
val  = [v0,  v1,  v2,  v3,  v1,  v2,  v3];

H = sparse(irow, icol, val);

% normalize along rows
H = diag(1./sum(H)) * H;

% apply the filter
r2 = H * r1;

