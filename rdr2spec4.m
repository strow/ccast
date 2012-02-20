%
% rdr2spec4 -- process RDR data to calibrated spectra
%
% Major processing steps are:
%   checkRDR  - validate the RDR data
%   scipack   - process sci and eng packets
%   readspec  - get count spectra
%   scanorder - group data into scans
%   movavg1   - local moving averages
%   calmain2  - radiometric calibration
%
% Notes
%   under development
%   
% Author
%   H. Motteler, 15 Nov 2011
%

addpath /home/motteler/cris/rdr2spec4
addpath /home/motteler/cris/rdr2spec4/davet2

% original RDR H5 data directory
dsrc  = '/asl/data/cris/rdr_proxy/hdf/2010/249';

% MIT matlab RDR data directory
dmit = '/asl/data/cris/rdr_proxy/mat/2010/249';
lmit = dir(sprintf('%s/RDR*.mat', dmit));

% NGAS matlab RDR data directory
% dngs = '/asl/data/cris/rdr_proxy/ng/2010/249';

% NGAS matlab filename and fov index for tests
% bngs = 'IGMB1F1Packet_000.mat';
% nfov = 1;

% initialize sci and eng packet struct's
eng1 = struct([]);
allsci = struct([]);

% moving average span is  2 * ms + 1
ms = 4;

% -------------------------
% loop on MIT RDR mat files
% -------------------------

% j = input('file index >');
% for fi = j

for fi = 1 : length(lmit)

% for fi = 1
 
% *** files with bad time ***
% rid = 'd20100906_t0722029';
% rid = 'd20100906_t1042018';

% *** from testSDR2 ***
% rid = 'd20100906_t1306010';
% rid = 'd20100906_t1314010';
  rid = 'd20100906_t1322009'; % starts with ES 1
% rid = 'd20100906_t1346008';
% rid = 'd20100906_t1354007';
% rid = 'd20100906_t1402007';

% *** files with ES time step too big
% rid = 'd20100906_t0402041';  % time step 601
% rid = 'd20100906_t0722029';  % time step 803
% rid = 'd20100906_t0954021';  % time step 96199
% rid = 'd20100906_t1506003';  % time step 400

% *** complex spike
% rid = 'd20100906_t1058017';

  % --------------------------
  % load and validate MIT data
  % --------------------------

  % MIT matlab RDR data file
  rid = lmit(fi).name(5:22);
  rmit = ['RDR_', rid, '.mat'];
  fmit = [dmit, '/', rmit];

  % skip dir if no file
  if ~exist(fmit, 'file')
    fprintf(1, 'MIT file missing, index %d file %s\n', fi, rid)
    continue
  end

  % load the MIT data, defines structures d1 and m1
  load(fmit)

  % RDR validation.  checkRDR returns data as nchan x 9 x nobs
  % arrays, ordered by time
  [igmLW, igmMW, igmSW, igmTime, igmFOR, igmSDR] = checkRDR5f(d1, rid);

  % process sci and eng packets
  [sci, eng] = scipack(d1, eng1);

  % this frees up a big chunk of memory
  clear d1

  % skip to next file if we don't have any science packets
  if isempty(sci)
    continue
  end

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

  continue  % ******************** TEMP **************************

  % ----------------------------------------------
  % get moving averages of SP and IT count spectra
  % ----------------------------------------------

  % the moving averages for the 2 sweep directions are kept
  % separate, as with the ES data parity gives the direction

  tmp1 = reshape(scLW(:, :, 31:32, :), nchLW * 9 * 2, nscan);
  avgLWSP = reshape(movavg1(tmp1, ms), nchLW, 9, 2, nscan);

  tmp1 = reshape(scLW(:, :, 33:34, :), nchLW * 9 * 2, nscan);
  avgLWIT = reshape(movavg1(tmp1, ms), nchLW, 9, 2, nscan);
 
  tmp1 = reshape(scMW(:, :, 31:32, :), nchMW * 9 * 2, nscan);
  avgMWSP = reshape(movavg1(tmp1, ms), nchMW, 9, 2, nscan);

  tmp1 = reshape(scMW(:, :, 33:34, :), nchMW * 9 * 2, nscan);
  avgMWIT = reshape(movavg1(tmp1, ms), nchMW, 9, 2, nscan);
 
  tmp1 = reshape(scSW(:, :, 31:32, :), nchSW * 9 * 2, nscan);
  avgSWSP = reshape(movavg1(tmp1, ms), nchSW, 9, 2, nscan);
 
  tmp1 = reshape(scSW(:, :, 33:34, :), nchSW * 9 * 2, nscan);
  avgSWIT = reshape(movavg1(tmp1, ms), nchSW, 9, 2, nscan);

  % -----------------------
  % radiometric calibration
  % -----------------------

  % calmain1 -- prototype with old code
  % calmain2 -- Dave's calibration code

  opt = struct;
  [rLW, vLW] = ...
     calmain2('lw', freqLW, scLW, scTime, avgLWIT, avgLWSP, sci, eng, opt);

  [rMW, vMW] = ...
     calmain2('mw', freqMW, scMW, scTime, avgMWIT, avgMWSP, sci, eng, opt);

  [rSW, vSW] = ...
     calmain2('sw', freqSW, scSW, scTime, avgSWIT, avgSWSP, sci, eng, opt);

  % ----------------
  % plots and images
  % ----------------

  % note for raw images: the data is in column and time order, with
  % rows individual ES FORs and columns successive scans.  Typically
  % we'd want to transpose this for an image, with the FORs in rows
  % going east/west and the scans in columns going north/south.

% % basic 1-FOV 1-freq image
% img1 = squeeze(real(rLW(400,5,:,:)));
% imagesc(img1')

  % all FOVs, 1-freq, need to get FOV tiling right
  img2 = zeros(90,3*nscan);
  for i = 1 : nscan
    for j = 1 : 30
      tt = reshape(squeeze(real(rLW(400,:,j,i))), 3, 3);
      ix = 3*(j-1)+1;
      iy = 3*(i-1)+1;
      img2(ix:ix+2, iy:iy+2) = tt;
    end
  end
  imagesc(img2')
  pause(1)

% % quick check to compare versions
% sum(real(rLW(~isnan(rLW(:)))))

end

