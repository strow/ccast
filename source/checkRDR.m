%
% NAME
%   checkRDR.m -- check and order RDR data from the MIT reader
%
% SYNOPSIS
%   [igmLW, igmMW, igmSW, igmTime, igmFOR, igmSDR] = checkRDR(d1, rid);
%
% INPUTS
%   d1   - data output struct from the MIT reader
%   rid  - RDR time and date substring, for messages
%
% OUTPUTS
%   igmLW   - nchan x 9 x nobs, LW interferograms
%   igmMW   - nchan x 9 x nobs, MW interferograms
%   igmSW   - nchan x 9 x nobs, SW interferograms
%   igmTime - nobs x 1, IGM times, ms since 1 Jan 1958
%   igmFOR  - nobs x 1, IGM FOR values, 0-31
%   igmSDR  - nobs x 1, IGM sweep direction, 0-1
%
% DISCUSSION
%   checkRDR puts the interferogram data in time order.  obs times are
%   sorted, merged, and duplicates are dropped, and some sanity checks
%   are done on the resulting timeline.  Steps in this timeline become
%   the nobs index, with obs times in igmTime.  Interferograms are moved
%   to an nchan x 9 x nobs grid and any gaps are filled with NaNs.
%
%   If the time intervals spanned by obs from successive RDR files do
%   not overlap, the output from successive calls to checkRDR can be
%   concatenated along the nobs dimension.
%
%   igmFOR distinguishes the ES, SP, and IT looks.  ES are 1-30, SP 31,
%   and IT 0.  igmSDR gives the sweep direction, 0 or 1.  Sanity checks
%   for igmFOR and igmSDR verify that they agree for simultaneous obs.
%
%   checkRDR should work for any file read_cris_hdf5_rdr can read.
%   A minor mod to the MIT v380 reader returns the interal variable
%   sweep_direction as DATA.sweep_dir.
%
%   The MIT reader returns days since 1 Jan 1958.  This is converted
%   to milliseconds since 1 Jan 1958 for internal processing and for
%   the values returned in igmTime.
%
% COPYRIGHT
%   Copyright 2011-2013, Atmospheric Spectroscopy Laboratory.  
%   This code is distributed under the terms of the GNU GPL v3.
%
% AUTHOR
%   H. Motteler, 26 Nov 2011
%

function [igmLW, igmMW, igmSW, igmTime, igmFOR, igmSDR] = checkRDR(d1, rid);

% milliseconds per day
msd = 8.64e7;

% initialize returned values
igmLW   = [];  igmMW   = [];  igmSW  = [];
igmTime = [];  igmFOR  = [];  igmSDR = [];

% ---------------------
% get a common timeline
% ---------------------

% sort and merge all 81 timelines (9 fovs x 3 bands x 3 obs types)
t1 = unique(msd * d1.packet.LWES.time(:));
t2 = unique(msd * d1.packet.LWIT.time(:));
t3 = unique(msd * d1.packet.LWSP.time(:));
t4 = unique(msd * d1.packet.MWES.time(:));
t5 = unique(msd * d1.packet.MWIT.time(:));
t6 = unique(msd * d1.packet.MWSP.time(:));
t7 = unique(msd * d1.packet.SWES.time(:));
t8 = unique(msd * d1.packet.SWIT.time(:));
t9 = unique(msd * d1.packet.SWSP.time(:));
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
% probably an error.  If it is less than 10 ms, the two steps are
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
igmSW = ones(n3, 9, nobs) * NaN;

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
  t1 = d1.packet.LWES.time(1:n, i) * msd;
  ix = interp1(igmTime, 1:nobs, t1, 'nearest');
  tmp1FOR(i, ix) = d1.FOR.LWES(i, 1:n);
  tmp1SDR(i, ix) = d1.sweep_dir.LWES(i, 1:n);
  igmLW(:, i, ix) =  d1.idata.LWES(:, i, 1:n) + ...
                1i * d1.qdata.LWES(:, i, 1:n);

  n = ztail(d1.packet.LWIT.time(:, i));
  t1 = d1.packet.LWIT.time(1:n, i) * msd;
  ix = interp1(igmTime, 1:nobs, t1, 'nearest');
  tmp1FOR(i, ix) = d1.FOR.LWIT(i, 1:n);
  tmp1SDR(i, ix) = d1.sweep_dir.LWIT(i, 1:n);
  igmLW(:, i, ix) =  d1.idata.LWIT(:, i, 1:n) + ...
                1i * d1.qdata.LWIT(:, i, 1:n);

  n = ztail(d1.packet.LWSP.time(:, i));
  t1 = d1.packet.LWSP.time(1:n, i) * msd;
  ix = interp1(igmTime, 1:nobs, t1, 'nearest');
  tmp1FOR(i, ix) = d1.FOR.LWSP(i, 1:n);
  tmp1SDR(i, ix) = d1.sweep_dir.LWSP(i, 1:n);
  igmLW(:, i, ix) =  d1.idata.LWSP(:, i, 1:n) + ...
                1i * d1.qdata.LWSP(:, i, 1:n);

  % --------------------------------
  % merge band 2 ES, IT, and SP data
  % --------------------------------
  n = ztail(d1.packet.MWES.time(:, i));
  t1 = d1.packet.MWES.time(1:n, i) * msd;
  ix = interp1(igmTime, 1:nobs, t1, 'nearest');
  tmp2FOR(i, ix) = d1.FOR.MWES(i, 1:n);
  tmp2SDR(i, ix) = d1.sweep_dir.MWES(i, 1:n);
  igmMW(:, i, ix) =  d1.idata.MWES(:, i, 1:n) + ...
                1i * d1.qdata.MWES(:, i, 1:n);

  n = ztail(d1.packet.MWIT.time(:, i));
  t1 = d1.packet.MWIT.time(1:n, i) * msd;
  ix = interp1(igmTime, 1:nobs, t1, 'nearest');
  tmp2FOR(i, ix) = d1.FOR.MWIT(i, 1:n);
  tmp2SDR(i, ix) = d1.sweep_dir.MWIT(i, 1:n);
  igmMW(:, i, ix) =  d1.idata.MWIT(:, i, 1:n) + ...
                1i * d1.qdata.MWIT(:, i, 1:n);

  n = ztail(d1.packet.MWSP.time(:, i));
  t1 = d1.packet.MWSP.time(1:n, i) * msd;
  ix = interp1(igmTime, 1:nobs, t1, 'nearest');
  tmp2FOR(i, ix) = d1.FOR.MWSP(i, 1:n);
  tmp2SDR(i, ix) = d1.sweep_dir.MWSP(i, 1:n);
  igmMW(:, i, ix) =  d1.idata.MWSP(:, i, 1:n) + ...
                1i * d1.qdata.MWSP(:, i, 1:n);

  % --------------------------------
  % merge band 3 ES, IT, and SP data
  % --------------------------------
  n = ztail(d1.packet.SWES.time(:, i));
  t1 = d1.packet.SWES.time(1:n, i) * msd;
  ix = interp1(igmTime, 1:nobs, t1, 'nearest');
  tmp3FOR(i, ix) = d1.FOR.SWES(i, 1:n);
  tmp3SDR(i, ix) = d1.sweep_dir.SWES(i, 1:n);
  igmSW(:, i, ix) =  d1.idata.SWES(:, i, 1:n) + ...
                1i * d1.qdata.SWES(:, i, 1:n);

  n = ztail(d1.packet.SWIT.time(:, i));
  t1 = d1.packet.SWIT.time(1:n, i) * msd;
  ix = interp1(igmTime, 1:nobs, t1, 'nearest');
  tmp3FOR(i, ix) = d1.FOR.SWIT(i, 1:n);
  tmp3SDR(i, ix) = d1.sweep_dir.SWIT(i, 1:n);
  igmSW(:, i, ix) =  d1.idata.SWIT(:, i, 1:n) + ...
                1i * d1.qdata.SWIT(:, i, 1:n);

  n = ztail(d1.packet.SWSP.time(:, i));
  t1 = d1.packet.SWSP.time(1:n, i) * msd;
  ix = interp1(igmTime, 1:nobs, t1, 'nearest');
  tmp3FOR(i, ix) = d1.FOR.SWSP(i, 1:n);
  tmp3SDR(i, ix) = d1.sweep_dir.SWSP(i, 1:n);
  igmSW(:, i, ix) =  d1.idata.SWSP(:, i, 1:n) + ...
                1i * d1.qdata.SWSP(:, i, 1:n);

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

