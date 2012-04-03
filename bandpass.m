%
% NAME
%   bandpass  -- simple bandpass filter
%
% SYNOPSIS
%   function dout = bandpass(din, vin, v1, v2, vr);
%
% INPUTS
%   din   - input data, m x n array, column order
%   vin   - input frequency, m-vector
%   v1    - passband start
%   v2    - passband end
%   vr    - passband rolloff, default 10
%
% OUTPUT
%   dout  - din, zeroed outside of [v1-vr, v2+vr]
%
% NOTES
%   the rolloff is a cosine from 0 to pi, fit to the interval vr
%
% AUTHOR
%    H. Motteler, 28 Apr 08

function dout = bandpass(din, vin, v1, v2, vr);

% set vr default value
if nargin < 5
  vr = 10;
end

% make input vin a column vector
vin = vin(:);

% check that inputs din and vin conform
[m,n] = size(din);
if length(vin) ~= m 
  error('vin length does not match din number of rows')
end

dv1 = vin(2) - vin(1);   % frequency step
rpts = round(vr / dv1);  % rolloff points
filt = zeros(m, 1);	 % initialize filter
dout = zeros(m,n);	 % initialize output

% get index of v1 and v2 in vin
i1 = interp1(vin, 1:m, v1, 'nearest');
i2 = interp1(vin, 1:m, v2, 'nearest');

if i1-rpts < 1 | m < i2+rpts-1 
  error('[v1-vr, v2+vr] is out of range')
end

% scale cosine from 0 to pi for rolloff
f0 = (1+cos(pi+(0:rpts-1)*pi/(rpts)))/2;

% build the filter
filt(i1-rpts:i1-1) = f0;
filt(i1:i2) = ones(i2-i1+1, 1);
filt(i2:i2+rpts-1) = fliplr(f0);

% apply the filter
for i = 1 : n
  dout(:,i) = din(:,i) .* filt;
end

