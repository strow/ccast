%
% L1a_to_SDR -- take ccast L1a to L1b/SDR files
%
% SYNOPSIS
%   L1a_to_SDR(flist, sdir, opts)
%
% INPUTS
%   flist  - list of L1b mat files
%   sdir   - directory for SDR output files
%   opts   - for now, everything else
%
% opts fields
%  opts for metlaser, inst_params, calmain, checkSDR, and mvspan
%   
% OUTPUT
%   SDR mat files
%
% DISCUSSION
%   the 2nd half of the old ccast function rdr2sdr
% 
% AUTHOR
%  H. Motteler, 26 Dec 2017
%

function L1a_to_SDR(flist, sdir, opts);

%----------------
% initialization
%----------------

% number of RDR files to process
nfile = length(flist);

% moving average span is 2 * mvspan + 1
mvspan = opts.mvspan;

%-----------------------
% loop on the L1b files
% ----------------------
for fi = 1 : nfile

  % matlab L1a input file
  Lfile = fullfile(flist(fi).folder, flist(fi).name);

  % matlab SDR output file
  ftmp = flist(fi).name;
  rid = ftmp(18:35);
  stmp = strrep(ftmp, 'L1a', 'SDR');
  sfile = fullfile(sdir, stmp);

  % print a short status message
  if exist(Lfile, 'file')
    fprintf(1, 'L1a_to_SDR: processing index %d file %s\n', fi, rid)
  else
    % skip processing if no matlab RDR file
    fprintf(1, 'L1a_to_SDR: RDR file missing, index %d file %s\n', fi, rid)
    continue
  end

  % load the RDR data, this defines structures d1 and m1
  load(Lfile)

 % check that we have sci data before we continue
  if isempty(sci)
    fprintf(1, 'rdr2sdr: no science packets, skipping file %s\n', rid)
    continue
  end

  % get the current wlaser from the eng packet data
  wlaser = metlaser(eng.NeonCal, opts);
  if isnan(wlaser)
    fprintf(1, 'rdr2sdr: no valid wlaser value, skipping file %s\n', rid)
    continue
  end

  % for now, just copy scGeo
  geo = scGeo;

  % for now, set L1a_err from scMatch
  [~, ~, ~, nscan] = size(scLW);
  L1a_err = reshape(~scMatch, 34, nscan);
  L1a_err = L1a_err(1:30, :);

% % set the L1a error flag
% [m, nscan] = size(scTime);
% L1a_err = isnan(geo.FORTime) | geo.FORTime < 0 | isnan(scTime(1:30, :)) ...
%           | cOR(geo.Latitude < -90 | 90 < geo.Latitude) ...
%           | cOR(geo.Longitude < -180 | 180 < geo.Longitude) ...
%           | abs(geo.FORTime ./ 1000 - (scTime(1:30, :) + geo.dtRDR)) > 1;

  if isempty(find(~L1a_err))
    fprintf(1, 'L1a_to_SDR: no valid L1a values, skipping file %s\n', rid)
    continue
  end

  % bad FOR warning message
  m = sum(L1a_err(:));
  if m > 0
    fprintf(1, 'L1a_to_SDR: warning - flagging %d bad FORs, file %s\n', m, rid)
  end

  %--------------------------
  % get uncalibrated spectra
  %--------------------------

  % get instrument and user grid parameters
  [instLW, userLW] = inst_params('LW', wlaser, opts);
  [instMW, userMW] = inst_params('MW', wlaser, opts);
  [instSW, userSW] = inst_params('SW', wlaser, opts);

  rcLW = igm2spec(scLW, instLW);
  rcMW = igm2spec(scMW, instMW);
  rcSW = igm2spec(scSW, instSW);

  clear scLW scMW scSW

  %--------------------------------------
  % radiometric and spectral calibration
  %--------------------------------------
  
  % get moving averages of SP and IT count spectra
  [avgLWSP, avgLWIT] = movavg_app(rcLW(:, :, 31:34, :), mvspan);
  [avgMWSP, avgMWIT] = movavg_app(rcMW(:, :, 31:34, :), mvspan);
  [avgSWSP, avgSWIT] = movavg_app(rcSW(:, :, 31:34, :), mvspan);

  [rLW, vLW, nLW] = calmain(instLW, userLW, rcLW, scTime, ...
                            avgLWIT, avgLWSP, sci, eng, geo, opts);

  [rMW, vMW, nMW] = calmain(instMW, userMW, rcMW, scTime, ...
                            avgMWIT, avgMWSP, sci, eng, geo, opts);

  [rSW, vSW, nSW] = calmain(instSW, userSW, rcSW, scTime, ...
                            avgSWIT, avgSWSP, sci, eng, geo, opts);

  clear rcLW rcMW rcSW

  % trim channel sets to user grid plus 2 guard channels
  % and return separate real values and complex residuals

  ugrid = cris_ugrid(userLW, 2);
  ix = interp1(vLW, 1:length(vLW), ugrid, 'nearest');
  cLW = single(imag(rLW(ix, :, :, :))); 
  rLW = single(real(rLW(ix, :, :, :)));  
  nLW = nLW(ix, :, :);
  vLW = vLW(ix);

  ugrid = cris_ugrid(userMW, 2);
  ix = interp1(vMW, 1:length(vMW), ugrid, 'nearest');
  cMW = single(imag(rMW(ix, :, :, :))); 
  rMW = single(real(rMW(ix, :, :, :))); 
  nMW = nMW(ix, :, :);
  vMW = vMW(ix);

  ugrid = cris_ugrid(userSW, 2);
  ix = interp1(vSW, 1:length(vSW), ugrid, 'nearest');
  cSW = single(imag(rSW(ix, :, :, :))); 
  rSW = single(real(rSW(ix, :, :, :))); 
  nSW = nSW(ix, :, :);
  vSW = vSW(ix);

  % L1b validation
  [L1b_err, L1b_stat] = ...
     checkSDR(vLW, vMW, vSW, rLW, rMW, rSW, cLW, cMW, cSW, ...
              userLW, userMW, userSW, L1a_err, rid, opts);

  %-------------------
  % save the SDR data
  %-------------------

  save(sfile, ...
       'instLW', 'instMW', 'instSW', 'userLW', 'userMW', 'userSW', ...
       'cLW', 'cMW', 'cSW', 'rLW', 'rMW', 'rSW', 'nLW', 'nMW', 'nSW', ...
       'vLW', 'vMW', 'vSW', 'scTime', 'sci', 'eng', 'geo', 'L1a_err', ...
       'L1b_err', 'L1b_stat', 'rid', '-v7.3')

end

