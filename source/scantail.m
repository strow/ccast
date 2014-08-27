%
% NAME
%   scantail - shift scan tail so output starts at FOR 1
%
% SYNOPSIS
%   [scLW, scMW, scSW, scTime, scTail] = ...
%         scantail(scLW, scMW, scSW, scTime, scTail)
%
% INPUTS
%   scLW   - nchan x 9 x 34 x nscan, LW rad counts
%   scMW   - nchan x 9 x 34 x nscan, MW rad counts
%   scSW   - nchan x 9 x 34 x nscan, SW rad counts
%   scTime - 34 x nscan, rad count times
%   scTail - scan tails
%
% OUTPUTS
%   same as inputs
%
% AUTHOR
%   H. Motteler, 26 Aug 2014
%

function [scLW, scMW, scSW, scTime, scTail] = ...
         scantail(scLW, scMW, scSW, scTime, scTail)

%-------------------------------------
% see if we can use the previous tail
%-------------------------------------

% get list of NaNs in column 1
head_nans = find(isnan(scTime(:, 1)));
head_isok = find(~isnan(scTime(:, 1)));

% this should never happen...
if isempty(head_isok)
  fprintf(1, 'scanorder: first column of scTime is all NaNs')
end

% check if head and previous tail match
if ~isempty(head_nans) ...
     &&  ~isempty(scTail.nans) ...
     &&  isequal([head_nans; scTail.nans], (1:34)')    
  
  head_first = scTime(min(head_isok), 1);
  if head_first - scTail.last < 620
  
    % copy data from the tail
    scLW(:, :, head_nans, 1) = scTail.scLW(:, :, head_nans);
    scMW(:, :, head_nans, 1) = scTail.scMW(:, :, head_nans);
    scSW(:, :, head_nans, 1) = scTail.scSW(:, :, head_nans);
    scTime(head_nans, 1) = scTail.scTime(head_nans);

  end
end

%-------------------------------
% save the current tail, if any
%-------------------------------

% get list of NaNs in tail
scTail = struct;
scTail.nans = find(isnan(scTime(:, end)));
tail_isok = find(~isnan(scTime(:, end)));

% this should never happen
if isempty(tail_isok)
  fprintf(1, 'scanorder: last column of scTime is all NaNs')
end

if ~isempty(scTail.nans)

  % save the tail
  scTail.scLW = scLW(:, :, :, end);
  scTail.scMW = scMW(:, :, :, end);
  scTail.scSW = scSW(:, :, :, end);
  scTail.scTime = scTime(:, end);
  scTail.last = scTime(max(tail_isok), end);

  % trim the returned data
  scLW = scLW(:, :, :, 1:end-1);
  scMW = scMW(:, :, :, 1:end-1);
  scSW = scSW(:, :, :, 1:end-1);
  scTime = scTime(:, 1:end-1);

end
