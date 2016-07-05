%
% NAME
%   resamp - CrIS resampling matrices
%
% SYNOPSIS
%   [R, frq2] = resamp(inst, user, algo)
%
% INPUTS
%   inst   - sensor grid struct
%   user   - user grid struct
%   algo   - resampling algorithm
%              0 = stock ATBD (default)
%              1 = ATBD with dv2 in the denominator
%              2 = ATBD NOAA/MIT with small N
%              3 = ATBD NOAA/MIT with big N
%              4 = sinc change of basis
%              5 = psinc change of basis
%
% OUTPUTS
%    R     - k x n resampling matrix
%   frq2   - resampled frequencies, k-vector
%
% DISCUSSION
%
%   the transform is applied as rad2 = R * rad1, where rad1 is at
%   the sensor grid.  frq2 is the corresponding output freqcy grid.
%
%   % ATBD algorithm without vectorization 
%   R = zeros(n2, n1);
%   for j = 1 : n1
%     for i = 1 : n2
%       R(i, j) = dv1 * sinc((frq1(j) - frq2(i)) / dv2) ...
%              / (dv2 * sinc((frq1(j) - frq2(i)) / (n1 * dv1)));
%     end
%   end
%
%   Algorighms (0) and (1) are very close in application.  Although
%   the implementation and formal descriptions are slightly different,
%   (1) and (2) give the same resampling matrices.  Algorithm (3) is
%   significantly closer to finterp than (2).  Algorithm (2) and (3)
%   converge to (4) as Nx -> infinity.
%
% HM, 6 Jun 2016
%

function [R, frq2] = resamp(inst, user, algo)

% default algo is stock ATBD
if nargin == 2
  algo = 0;
end

% sensor grid params
dv1 = inst.dv;
frq1 = inst.freq;
n1 = inst.npts;

% user grid max subset
dv2 = user.dv;
k1 = ceil(frq1(1) / dv2);
k2 = floor(frq1(end) / dv2);
frq2 = (k1 : k2)' * dv2;
n2 = length(frq2);

% initialize resampling matrix
R = zeros(n2, n1);

% choose an algorithm
switch (algo)
case 0  % stock ATBD
  for j = 1 : n1
    R(:, j) = dv1 * sinc((frq1(j) - frq2) / dv2) ...
          ./ (dv2 * sinc((frq1(j) - frq2) / (n1 * dv1)));
  end

case 1  % ATBD with dv2 in the denominator
  for j = 1 : n1
    R(:, j) = dv1 * sinc((frq1(j) - frq2) / dv2) ...
          ./ (dv2 * sinc((frq1(j) - frq2) / (n1 * dv2)));
  end

case 2  % NOAA/MIT transform small N
  Nx = inst.npts;
  for j = 1 : n1
    R(:, j) = dv1 * sin(pi * (frq1(j) - frq2) / dv2) ...
          ./ (dv2 * Nx * sin(pi * (frq1(j) - frq2) / (Nx * dv2)));
  end

case 3  % NOAA/MIT transform big N
% fprintf(1, 'algo 3, NOAA/MIT transform big N\n')
  Nx = inst.npts * inst.df;
  for j = 1 : n1
    R(:, j) = dv1 * sin(pi * (frq1(j) - frq2) / dv2) ...
          ./ (dv2 * Nx * sin(pi * (frq1(j) - frq2) / (Nx * dv2)));
  end

case 4  % sinc change of basis
% fprintf(1, 'algo 4, sinc change of basis\n') 
  for j = 1 : n1
    R(:, j) = dv1 * sinc((frq1(j) - frq2) / dv2) / dv2;
  end

case 5  % psinc change of basis
% fprintf(1, 'algo 5, psinc change of basis\n') 
  for j = 1 : n1
    R(:, j) = dv1 * psinc((frq1(j) - frq2) / dv2, n1) / dv2;
  end

end % switch
end % resamp

%
% NAME
%   psinc -- normalized periodic sinc
%
% SYNOPSIS
%   y = psinc(x, n)
%

function y = psinc(x, n)

x = x * pi;

y = sin(x) ./ (n * sin(x/n));

y(find(x==0)) = 1;

end % psinc

