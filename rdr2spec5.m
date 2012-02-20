%
% rdr2spec5 -- process RDR data to calibrated spectra
%
% Major processing steps are:
%   checkRDR   - validate the RDR data
%   scipack    - process sci and eng packets
%   readspec   - get count spectra
%   scanorder  - group data into scans
%   movavg_app - get moving averages
%   calmain2   - radiometric calibration
%
% Notes
%   under development
%   
% Author
%   H. Motteler, 15 Nov 2011
%

addpath /home/motteler/cris/rdr2spec5
addpath /home/motteler/cris/rdr2spec5/davet2

% matlab RDR data directory
% rdir = '/asl/data/cris/rdr_proxy/mat/2010/249';
rdir = '/asl/data/cris/rdr60/mat/2012/038';

flist = dir(sprintf('%s/RDR*.mat', rdir));
nfile = length(flist);

% moving averages directory 
adir = '/strowdata2/s2/motteler/cris/2012/038';

% moving average span is 2 * mspan + 1
mspan = 4;

% initialize sci and eng packet struct's
eng1 = struct([]);
allsci = struct([]);

% -------------------------
% loop on MIT RDR mat files
% -------------------------

for fi = 7 : nfile

  % --------------------------
  % load and validate MIT data
  % --------------------------

  % MIT matlab RDR data file
  rid = flist(fi).name(5:22);
  rtmp = ['RDR_', rid, '.mat'];
  rfile = [rdir, '/', rtmp];

  % moving average filenames
  atmp = ['AVG_', rid, '.mat'];
  afile = [adir, '/', atmp];

  % skip processing if no matlab RDR file
  if ~exist(rfile, 'file')
    fprintf(1, 'RDR file missing, index %d file %s\n', fi, rid)
    continue
  end

  % load the RDR data, defines structures d1 and m1
  load(rfile)

  % RDR validation.  checkRDR returns data as nchan x 9 x nobs
  % arrays, ordered by time
  [igmLW, igmMW, igmSW, igmTime, igmFOR, igmSDR] = checkRDR5f(d1, rid);

  if isempty(igmTime)
    fprintf(1, '[main]: no valid data, skipping file %s\n', rid)
    continue
  end

  % process sci and eng packets
  [sci, eng] = scipack(d1, eng1);

  % this frees up a big chunk of memory
  clear d1

  % skip to next file if we don't have any science packets
  if isempty(sci)
    fprintf(1, '[main]: no science packets, skipping file %s\n', rid)
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

  % ----------------------------------------------
  % get moving averages of SP and IT count spectra
  % ----------------------------------------------

  if exist(afile) == 2
    load(afile)
  else
    [avgLWSP, avgLWIT] = movavg_app(scLW(:, :, 31:34, :), mspan);
    [avgMWSP, avgMWIT] = movavg_app(scMW(:, :, 31:34, :), mspan);
    [avgSWSP, avgSWIT] = movavg_app(scSW(:, :, 31:34, :), mspan);
  end

% continue  % ******************** TEMP **************************

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
  ch = 373;
  img_re = zeros(90,3*nscan);
  img_im = zeros(90,3*nscan);
  for i = 1 : nscan
    for j = 1 : 30
      t_re = reshape(squeeze(real(rLW(ch,:,j,i))), 3, 3);
      t_im = reshape(squeeze(imag(rLW(ch,:,j,i))), 3, 3);
      ix = 3*(j-1)+1;
      iy = 3*(i-1)+1;
      img_re(ix:ix+2, iy:iy+2) = t_re;
      img_im(ix:ix+2, iy:iy+2) = t_im;
    end
  end

  figure (1)
  imagesc(img_re')
  title([rid(2:9), ' ', rid(12:17), ' real'])
  xlabel('cross track FOV')
  ylabel('along track FOV')
  colorbar
  saveas(gcf, [rid(11:17), 'real'], 'fig')

  figure(2)
  imagesc(img_im')
  title([rid(2:9), ' ', rid(12:17), ' imag'])
  xlabel('cross track FOV')
  ylabel('along track FOV')
  colorbar
  saveas(gcf, [rid(11:17), 'imag'], 'fig')

  rid
  pause

% % quick check to compare versions
% sum(real(rLW(~isnan(rLW(:)))))

end

