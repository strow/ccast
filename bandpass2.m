%
% NAME
%   bandpass2  -- simple bandpass filter
%
% SYNOPSIS
%   function dout = bandpass2(vin, din, v1, v2);
%
% INPUTS
%   vin   - input frequency grid, m-vector
%   din   - input data, m x n array, column order
%   v1    - passband start
%   v2    - passband end
%
% OUTPUT
%   dout  - din rolled off to band edges outside of [v1, v2]
%
% NOTES
%   the rolloff is a cosine, fit vin(1) to v1 and v2 to vin(end)
%
% AUTHOR
%    H. Motteler, 20 Apr 2012

function dout = bandpass2(vin, din, v1, v2)

% make vin a column vector
vin = vin(:);

% check that inputs vin and din conform
[m, n] = size(din);
if length(vin) ~= m
  error('vin length and din rows differ')
end

% get passband indices in vin
j1 = max(find(vin <= v1));
j2 = min(find(v2 <= vin));

% get sizes of each segment
n1 = j1 - 1;       % points in LHS rolloff
n3 = j2 - j1 + 1;  % points in passband
n2 = m - j2;       % points in RHS rolloff

% scale cosine for the rolloffs
f1 = (1+cos(pi+(0:n1-1)*pi/n1))/2;
f2 = (1+cos((1:n2)*pi/n2))/2;

% build the filter
filt = [f1, ones(1,n3), f2]';

% apply the filter
for i = 1 : n
  dout(:,i) = din(:,i) .* filt;
end

