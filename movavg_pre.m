%
% movavg_pre -- preprocess moving averages
%
% Major processing steps are:
%   checkRDR   - validate the RDR data
%   readspec   - get count spectra
%   scanorder  - group data into scans
%   movavg_aux - get moving averages
%
% Notes
%   under development
%
% Author
%   H. Motteler, 8 Jan 2012
%

% matlab RDR data directory
rdir = '/asl/data/cris/rdr_proxy/mat/2010/249';
flist = dir(sprintf('%s/RDR*.mat', rdir));
nfile = length(flist);

% moving averages directory
adir = '/strowdata2/s2/motteler/cris/2010/249';

% moving average span is 2 * mspan + 1
mspan = 4;

% initial 3-file windows
favg = '';
c2LW = [];
c2MW = [];
c2SW = [];
c3LW = [];
c3MW = [];
c3SW = [];

% ---------------------
% loop on RDR mat files
% ---------------------

for fi = 1 : nfile

  % --------------------------
  % load and validate RDR data
  % --------------------------

  % MIT matlab RDR data file
  rid = flist(fi).name(5:22);
  rtmp = ['RDR_', rid, '.mat'];
  fRDR = [rdir, '/', rtmp];

  % moving average filenames
  fprev = favg;
  rtmp = ['AVG_', rid, '.mat'];
  favg = [adir, '/', rtmp];

  % skip processing if no matlab RDR file
  if ~exist(fRDR, 'file')
    fprintf(1, 'RDR mat file missing, index %d file %s\n', fi, rid)
    continue
  end

  % load the RDR data, defines structures d1 and m1
  load(fRDR)

  % RDR validation.  checkRDR returns data as nchan x 9 x nobs
  % arrays, ordered by time
  [igmLW, igmMW, igmSW, igmTime, igmFOR, igmSDR] = checkRDRf(d1, rid);

  % this frees up a big chunk of memory
  clear d1

  % -----------------
  % get count spectra
  % -----------------

  opts = struct;
  opts.wlaser = 773.36596; % from Feb 08 laser test
  [rcLW, freqLW, optsLW] = readspec6(igmLW, 'LW', opts);
  [rcMW, freqMW, optsMW] = readspec6(igmMW, 'MW', opts);
  [rcSW, freqSW, optsSW] = readspec6(igmSW, 'SW', opts);

  [nchLW, m, n] = size(rcLW);
  [nchMW, m, n] = size(rcMW);
  [nchSW, m, n] = size(rcSW);

  clear igmLW igmMW igmSW

  % ---------------------
  % group data into scans
  % ---------------------

  % Move obs to an nchan x 9 x 34 x nscan array, with gaps filled
  % with NaNs.  In the 3rd dim, indices 1:30 are ES data, 31:32 SP,
  % and 33:34 IT.  The time and FOR outputs are 34 x nscan arrays.  
  % Note that if the data from checkRDR has no time or FOR gaps and
  % starts with FOR 1, this is just a reshape.

  [scLW, scMW, scSW, scTime, scFOR] = ...
           scanorder2(rcLW, rcMW, rcSW, igmTime, igmFOR, igmSDR, rid);

  [m, n, k, nscan] = size(scLW);

  clear rcLW rcMW rcSW

  % ----------------------------
  % do the 3-file moving average
  % ----------------------------

  % shift the 3-file window up one 
  c1LW = c2LW;
  c1MW = c2MW;
  c1SW = c2SW;

  c2LW = c3LW;
  c2MW = c3MW;
  c2SW = c3SW;

  c3LW = scLW(:, :, 31:34, :);
  c3MW = scMW(:, :, 31:34, :);
  c3SW = scSW(:, :, 31:34, :);
  
  clear scLW scMW scSW

  % the first iteration sets up the moving window
  if fi == 1
    continue
  end

  [avgLWSP, avgLWIT] = movavg_aux(c1LW, c2LW, c3LW, mspan);
  [avgMWSP, avgMWIT] = movavg_aux(c1MW, c2MW, c3MW, mspan);
  [avgSWSP, avgSWIT] = movavg_aux(c1SW, c2SW, c3SW, mspan);

  save(fprev, 'avgLWSP', 'avgLWIT', ...
              'avgMWSP', 'avgMWIT', ...
              'avgSWSP', 'avgSWIT');

end % loop on RDR mat files

% ------------------
% do the final shift
% ------------------
c1LW = c2LW;
c1MW = c2MW;
c1SW = c2SW;

c2LW = c3LW;
c2MW = c3MW;
c2SW = c3SW;

c3LW = [];
c3MW = [];
c3SW = [];

% ---------------------------
% do the final moving average
% ---------------------------

[avgLWSP, avgLWIT] = movavg_aux(c1LW, c2LW, c3LW, mspan);
[avgMWSP, avgMWIT] = movavg_aux(c1MW, c2MW, c3MW, mspan);
[avgSWSP, avgSWIT] = movavg_aux(c1SW, c2SW, c3SW, mspan);

save(favg, 'avgLWSP', 'avgLWIT', ...
           'avgMWSP', 'avgMWIT', ...
           'avgSWSP', 'avgSWIT');

% end % movavg_pre

