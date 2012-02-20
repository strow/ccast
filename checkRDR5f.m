%
% NAME
%   checkRDR5f.m - validate RDR data from the MIT reader
%
% SYNOPSIS
%   [igmLW, igmMW, igmSW, igmTime, igmFOR, igmSDR] = checkRDR5f(d1, rid);
%
% INPUTS
%   d1  - output structure from MIT reader
%   rid - RDR file time and date substring (for error messages)
%
% OUTPUTS
%   igmLW   - nchan x 9 x nobs, LW pseudo-interferograms
%   igmMW   - nchan x 9 x nobs, MW pseudo-interferograms
%   igmSW   - nchan x 9 x nobs, SW pseudo-interferograms
%   igmTime - nobs x 1, IGM times, millseconds since 1 Jan 1958
%   igmFOR  - nobs x 1, IGM FOR values, 0-31
%   igmSDR  - nobs x 1, IGM sweep direction
%
% DISCUSSION
%
% The output data (in column order) is ordered by time.  
%
% This version of checkRDR is a function that returns the merge of
% the ES, IT, and SP interferograms, with FOR flags, sorted by time.
% It is derived from the script checkRDR4 and is a total rewrite of
% checkRDR3.  The key difference is that checkRDR3 drops obs indices
% when all time fields were not identical while checkRDR4 merges all
% 81 timelines (9 fovs x 3 bands x 3 obs types) to a single sorted
% list of unique times, does some QC on this list, fits all obs to
% the merged timeline, and fills any gaps with NaNs.
%
% NOTES
% 
% NGAS and geo time appears to be milliseconds since 1 Jan 1958,
% roughly 52.7 * 365.25 * 24 * 60 * 60 * 1000
% 
% t_mit * 8.64e7 = t_ngas.  There are 8.64e7 ms in a day, so the 
% MIT time is days since 1 Jan 1958
%
% The time in the test data is about 200 ms between the ES FORs and
% about 2 sec and between ES scans, in agreement with the ATBD spec
%
% The NGAS and MIT FOR numbering has IT=0 and SP=31.  According to
% the Bomem ATBD SP=0 and IT=31, but maybe that's out of date.
%
% Many of the MIT arrays, including time, igm data, FOR flags, and
% ICT parameters, are padded with zeros past the actual end point.
%
% AUTHOR
%   H. Motteler, 26 Nov 2011
%

function [igmLW, igmMW, igmSW, igmTime, igmFOR, igmSDR] = checkRDR5f(d1, rid);

% factor to convert MIT time to IET, t_mit * mwt = t_ngas
mwt = 8.64e7;

% initialize returned values
igmLW   = [];  igmMW   = [];  igmSW  = [];
igmTime = [];  igmFOR  = [];  igmSDR = [];

% ---------------------
% get a common timeline
% ---------------------

% sort and merge all 81 timelines (9 fovs x 3 bands x 3 obs types)
t1 = unique(mwt * d1.packet.LWES.time(:));
t2 = unique(mwt * d1.packet.LWIT.time(:));
t3 = unique(mwt * d1.packet.LWSP.time(:));
t4 = unique(mwt * d1.packet.MWES.time(:));
t5 = unique(mwt * d1.packet.MWIT.time(:));
t6 = unique(mwt * d1.packet.MWSP.time(:));
t7 = unique(mwt * d1.packet.SWES.time(:));
t8 = unique(mwt * d1.packet.SWIT.time(:));
t9 = unique(mwt * d1.packet.SWSP.time(:));
t0 = unique([t1;t2;t3;t4;t5;t6;t7;t8;t9]);

% check for valid timeline
if isempty(t0)
  fprintf(1, 'checkRDR: no valid time values, file %s\n', rid);
  return
end

% drop an initial zero, if present (from zeros in the array tails)
if t0(1) == 0
  t0 = t0(2:length(t0));
end

% check that the min and max time steps are sensible.  10 ms is 5
% pct of a 200 ms ES FOR step.  A time step of less than 190 ms is
% probably an error.  If it'is less than 10 ms, the two steps are
% probably equal so drop the first.

dt0 = diff(t0);
dmin = min(dt0);
if dmin < 190
  fprintf(1, 'checkRDR: time step %.1f too small, file %s\n', dmin, rid);
  if dmin < 10
    % drop the first time value for pairs within 10 ms
    t0 = t0([1>0; dt0 >= 10]);
    fprintf(1, 'checkRDR: dropped duplicate time step, file %s\n', rid);
  end
end

dmax = max(dt0);
if dmax > 8000
  % looks like we lost at least one scan
  fprintf(1, 'checkRDR: time step %.0f too big, file %s\n', dmax, rid);
end

% save the results
igmTime = t0;
nobs = length(igmTime);

% ---------------------------
% move data to a regular grid
% ---------------------------

% get sizes for output arrays
[n1, m, k] = size(d1.idata.LWES);
[n2, m, k] = size(d1.idata.MWES);
[n3, m, k] = size(d1.idata.SWES);

% initialize output arrays to NaNs
igmLW = ones(n1, 9, nobs) * NaN;
igmMW = ones(n2, 9, nobs) * NaN;
igmsW = ones(n3, 9, nobs) * NaN;

tmp1FOR = ones(9, nobs) * NaN;
tmp2FOR = ones(9, nobs) * NaN;
tmp3FOR = ones(9, nobs) * NaN;
igmFOR = ones(nobs, 1) * NaN;

tmp1SDR = ones(9, nobs) * NaN;
tmp2SDR = ones(9, nobs) * NaN;
tmp3SDR = ones(9, nobs) * NaN;
igmSDR = ones(nobs, 1) * NaN;

% loop on FOVs, merge ES, IT, and SP data
for i = 1 : 9

  % --------------------------------
  % merge band 1 ES, IT, and SP data
  % --------------------------------
  n = ztail(d1.packet.LWES.time(:, i));
  t1 = d1.packet.LWES.time(1:n, i) * mwt;
  ix = interp1(igmTime, 1:nobs, t1, 'nearest');
  tmp1FOR(i, ix) = d1.FOR.LWES(i, 1:n);
  tmp1SDR(i, ix) = d1.sweep_dir.LWES(i, 1:n);
  igmLW(:, i, ix) =  d1.idata.LWES(:, i, 1:n) + ...
          sqrt(-1) * d1.qdata.LWES(:, i, 1:n);

  n = ztail(d1.packet.LWIT.time(:, i));
  t1 = d1.packet.LWIT.time(1:n, i) * mwt;
  ix = interp1(igmTime, 1:nobs, t1, 'nearest');
  tmp1FOR(i, ix) = d1.FOR.LWIT(i, 1:n);
  tmp1SDR(i, ix) = d1.sweep_dir.LWIT(i, 1:n);
  igmLW(:, i, ix) =  d1.idata.LWIT(:, i, 1:n) + ...
          sqrt(-1) * d1.qdata.LWIT(:, i, 1:n);

  n = ztail(d1.packet.LWSP.time(:, i));
  t1 = d1.packet.LWSP.time(1:n, i) * mwt;
  ix = interp1(igmTime, 1:nobs, t1, 'nearest');
  tmp1FOR(i, ix) = d1.FOR.LWSP(i, 1:n);
  tmp1SDR(i, ix) = d1.sweep_dir.LWSP(i, 1:n);
  igmLW(:, i, ix) =  d1.idata.LWSP(:, i, 1:n) + ...
          sqrt(-1) * d1.qdata.LWSP(:, i, 1:n);

  % --------------------------------
  % merge band 2 ES, IT, and SP data
  % --------------------------------
  n = ztail(d1.packet.MWES.time(:, i));
  t1 = d1.packet.MWES.time(1:n, i) * mwt;
  ix = interp1(igmTime, 1:nobs, t1, 'nearest');
  tmp2FOR(i, ix) = d1.FOR.MWES(i, 1:n);
  tmp2SDR(i, ix) = d1.sweep_dir.MWES(i, 1:n);
  igmMW(:, i, ix) =  d1.idata.MWES(:, i, 1:n) + ...
          sqrt(-1) * d1.qdata.MWES(:, i, 1:n);

  n = ztail(d1.packet.MWIT.time(:, i));
  t1 = d1.packet.MWIT.time(1:n, i) * mwt;
  ix = interp1(igmTime, 1:nobs, t1, 'nearest');
  tmp2FOR(i, ix) = d1.FOR.MWIT(i, 1:n);
  tmp2SDR(i, ix) = d1.sweep_dir.MWIT(i, 1:n);
  igmMW(:, i, ix) =  d1.idata.MWIT(:, i, 1:n) + ...
          sqrt(-1) * d1.qdata.MWIT(:, i, 1:n);

  n = ztail(d1.packet.MWSP.time(:, i));
  t1 = d1.packet.MWSP.time(1:n, i) * mwt;
  ix = interp1(igmTime, 1:nobs, t1, 'nearest');
  tmp2FOR(i, ix) = d1.FOR.MWSP(i, 1:n);
  tmp2SDR(i, ix) = d1.sweep_dir.MWSP(i, 1:n);
  igmMW(:, i, ix) =  d1.idata.MWSP(:, i, 1:n) + ...
          sqrt(-1) * d1.qdata.MWSP(:, i, 1:n);

  % --------------------------------
  % merge band 3 ES, IT, and SP data
  % --------------------------------
  n = ztail(d1.packet.SWES.time(:, i));
  t1 = d1.packet.SWES.time(1:n, i) * mwt;
  ix = interp1(igmTime, 1:nobs, t1, 'nearest');
  tmp3FOR(i, ix) = d1.FOR.SWES(i, 1:n);
  tmp3SDR(i, ix) = d1.sweep_dir.SWES(i, 1:n);
  igmSW(:, i, ix) =  d1.idata.SWES(:, i, 1:n) + ...
          sqrt(-1) * d1.qdata.SWES(:, i, 1:n);

  n = ztail(d1.packet.SWIT.time(:, i));
  t1 = d1.packet.SWIT.time(1:n, i) * mwt;
  ix = interp1(igmTime, 1:nobs, t1, 'nearest');
  tmp3FOR(i, ix) = d1.FOR.SWIT(i, 1:n);
  tmp3SDR(i, ix) = d1.sweep_dir.SWIT(i, 1:n);
  igmSW(:, i, ix) =  d1.idata.SWIT(:, i, 1:n) + ...
          sqrt(-1) * d1.qdata.SWIT(:, i, 1:n);

  n = ztail(d1.packet.SWSP.time(:, i));
  t1 = d1.packet.SWSP.time(1:n, i) * mwt;
  ix = interp1(igmTime, 1:nobs, t1, 'nearest');
  tmp3FOR(i, ix) = d1.FOR.SWSP(i, 1:n);
  tmp3SDR(i, ix) = d1.sweep_dir.SWSP(i, 1:n);
  igmSW(:, i, ix) =  d1.idata.SWSP(:, i, 1:n) + ...
          sqrt(-1) * d1.qdata.SWSP(:, i, 1:n);

end % loop on FOVs

% ---------------------------------
% check that FOR agrees for all FOVs
% ---------------------------------

% combine FOR lists for all 3 bands
t1 = max([tmp1FOR; tmp2FOR; tmp3FOR]);
t2 = min([tmp1FOR; tmp2FOR; tmp3FOR]);
igmFOR = t1(:);  
t1(isnan(t1)) = -1;
t2(isnan(t2)) = -1;
if ~isequal(t1,t2)
   fprintf(1, 'checkRDR: FOV FORs differ, index %d file %s\n', ri, rid);
end

% combine SDR lists for all 3 bands
t1 = max([tmp1SDR; tmp2SDR; tmp3SDR]);
t2 = min([tmp1SDR; tmp2SDR; tmp3SDR]);
igmSDR = t1(:);
t1(isnan(t1)) = -1;
t2(isnan(t2)) = -1;
if ~isequal(t1,t2)
   fprintf(1, 'checkRDR: FOV sweeps differ, index %d file %s\n', ri, rid);
end

