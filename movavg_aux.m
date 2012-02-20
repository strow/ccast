%
% NAME
%   movavg_aux - get moving average from a 3-file window
%
% SYNOPSIS
%   function [avgSP, avgIT] = movavg_aux(c1, c2, c3, mspan);
%
% INPUTS
%   c1    - head, use the last mspan scans
%   c2    - main window file, use all scans
%   c3    - tail, use the first mspan scans
%   mspan - moving average of 2*mspan+1 scans
%
% OUTPUTS
%   avgSP - moving average of SP values, spans files
%   avgIT - moving average of IT values, spans files
%

function [avgSP, avgIT] = movavg_aux(c1, c2, c3, mspan);

% reshape c1 and trim all but the last mspan scans
if isempty(c1)
  tmp1 = [];
  ind1 = 0;
else
  [nchan, n, k, nscan1] = size(c1);
  tmp1 = reshape(c1, nchan * 9 * 4, nscan1);
  tmp1 = tmp1(:, max(1, nscan1-mspan+1) : nscan1);
  [m, ind1] = size(tmp1);
end

% reshape c2, the main body of the moving average
[nchan, n, k, nscan2] = size(c2);
tmp2 = reshape(c2, nchan * 9 * 4, nscan2);

% reshape c3 and trim all but the first mspan scans
if isempty(c3)
  tmp3 = [];
  ind3 = 0;
else
  [nchan, n, k, nscan3] = size(c3);
  tmp3 = reshape(c3, nchan * 9 * 4, nscan3);
  tmp3 = tmp3(:, 1 : min(mspan, nscan3));
  [m, ind3] = size(tmp3);
end

% take the moving average of the extended interval
tmp = [tmp1, tmp2, tmp3];
tmp = movavg1(tmp, mspan);

% trim the result to the size of c2
[m, n] = size(tmp);
tmp = tmp(:, 1+ind1 : n-ind3);

% reshape and split off SP and IT parts
tmp = reshape(tmp, nchan, 9, 4, nscan2);
avgSP = tmp(:, :, 1:2, :);
avgIT = tmp(:, :, 3:4, :);

end % movavg_aux

