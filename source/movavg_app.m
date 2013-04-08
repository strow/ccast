%
% NAME
%   movavg_app - take moving average of SP and IT data
%
% SYNOPSIS
%   function [avgSP, avgIT] = movavg_app(scal, mspan)
%
% INPUTS
%   scal  - nchan x 9 x 4 x nscan, ICT and SP scans
%   mspan - calculate a 2*mspan + 1 moving average 
%
% OUTPUTS
%   avgSP - moving average of SP values
%   avgIT - moving average of IT values
%

function [avgSP, avgIT] = movavg_app(scal, mspan)

[nchan, n, k, nscan] = size(scal);
tmp = reshape(scal, nchan * 9 * 4, nscan);
tmp = reshape(movavg1(tmp, mspan), nchan, 9, 4, nscan);
avgSP = tmp(:, :, 1:2, :);
avgIT = tmp(:, :, 3:4, :);

