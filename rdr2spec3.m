%
% rdr2spec3 -- process RDR data to calibrated spectra
%
% derived from rdr2spec2
%
% Major processing steps are:
% 
% Loop on RDR mat files from the MIT RDR reader.  
%
% Data is validated with the function checkRDR, which checks ES, SP,
% and IT time, FOR, and IGM data for consistecy and returns the merge
% of the ES, IT, and SP interferograms with FOR flags, sorted by time.
% 
% The interferograms are processed to count spectra by readspec6 and
% then separated into ES (earth scenes) and the IT and SP calibration
% data, by the FOR flags.  The ES data is grouped into swaths, and a
% moving average is taken of the IT and SP data.
% 
% Basic linear calibration is 
%
%   Re  = Ri - (Ci - Ce) * (Ri - Rs) / (Ci - Cs)
%
% where
%   Re  =  earth scene radiance
%   Ce  =  earth scene count spectra
%   Ri  =  internal target radiance 
%   Ci  =  internal target count spectra
%   Rs  =  space background radiance
%   Cs  =  space background count spectra
% 
% Notes
% 
% Currently the SP and IT averages don't span files.  The simplest
% way to fix that is to make two passes thru the data.
% 
% The ICT BB calc needs an emissivity factor
%
% Author
%   H. Motteler, 30 Oct 2011
%

% original RDR H5 data directory
dsrc  = '/asl/data/cris/Proxy/2010/09/06';

% MIT matlab RDR data directory
dmit = '/asl/data/cris/mott/2010/09/06mit';
lmit = dir(sprintf('%s/RDR*.mat', dmit));

% NGAS matlab RDR data directory
% dngs = '/asl/data/cris/mott/2010/09/06';

% NGAS matlab filename and fov index for tests
% bngs = 'IGMB1F1Packet_000.mat';
% nfov = 1;

% temp stats
fov1stats = zeros(32,1);

% -------------------------
% loop on MIT RDR mat files
% -------------------------

% j = input('file index >');
% for fi = j

for fi = 1 : length(lmit)

% for fi = 1
 
% *** temp files with bad time ***
% rid = 'd20100906_t0722029';
% rid = 'd20100906_t1042018';

% *** temp from testSDR2 ***
% rid = 'd20100906_t1306010';
% rid = 'd20100906_t1314010';
% rid = 'd20100906_t1322009';
% rid = 'd20100906_t1346008';
% rid = 'd20100906_t1354007';
% rid = 'd20100906_t1402007';

% *** temp files with ES time step too big
% rid = 'd20100906_t0402041';  % time step 601
% rid = 'd20100906_t0722029';  % time step 803
% rid = 'd20100906_t0954021';  % time step 96199
% rid = 'd20100906_t1506003';  % time step 400

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

  % RDR validation
  % checkRDR returns data as a nchan x 9 x nobs arrays
  [igmLW, igmMW, igmSW, igmTime, igmFOR] = checkRDR4f(d1, rid);

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

  % ----------------------
  % group data into swaths
  % ----------------------

  % Move obs to an nchan x 9 x 34 x nswath array, with gaps filled
  % with NaNs.  In the 3rd dim, indices 1:30 are ES data, 31:32 SP,
  % and 33:34 IT.  Note that if the data from checkRDR has no time
  % or FOR gaps and starts with FOR 1, this is just a reshape.

  [swLW, swMW, swSW, swTime, swFOR] = ...
                 scanorder(rcLW, rcMW, rcSW, igmTime, igmFOR, rid);

  [m, n, k, nswath] = size(swLW);

  clear rcLW rcMW rcSW

  % ----------------------------------------------
  % get moving averages of SP and IT count spectra
  % ----------------------------------------------

  tmp1 = reshape(swLW(:, :, 31:32, :), nchLW * 9, nswath * 2);
  avgLWSP = reshape(movavg1(tmp1, 4), nchLW, 9, 2, nswath);

  tmp1 = reshape(swLW(:, :, 33:34, :), nchLW * 9, nswath * 2);
  avgLWIT = reshape(movavg1(tmp1, 4), nchLW, 9, 2, nswath);
 
  tmp1 = reshape(swMW(:, :, 31:32, :), nchMW * 9, nswath * 2);
  avgMWSP = reshape(movavg1(tmp1, 4), nchMW, 9, 2, nswath);

  tmp1 = reshape(swMW(:, :, 33:34, :), nchMW * 9, nswath * 2);
  avgMWIT = reshape(movavg1(tmp1, 4), nchMW, 9, 2, nswath);
 
  tmp1 = reshape(swSW(:, :, 31:32, :), nchSW * 9, nswath * 2);
  avgSWSP = reshape(movavg1(tmp1, 4), nchSW, 9, 2, nswath);
 
  tmp1 = reshape(swSW(:, :, 33:34, :), nchSW * 9, nswath * 2);
  avgSWIT = reshape(movavg1(tmp1, 4), nchSW, 9, 2, nswath);

  % --------------------------------
  % do basic radiometric calibration
  % --------------------------------

  % space temperature
  spt = 2.7279;

  % get average of ICT temps
  [ict1, ict2] = getICTtemp(d1);
  ict = (ict1 + ict2) / 2;

  if nswath == 0 || isempty(ict)
    fprintf(1, 'not enough data for calibration, file %s\n', rid)
    continue
  end

  % get black-body spectra for IT and SP.  needs emissivity factor
  % for now, treat all FOVs as identical
  rLWIT = bt2rad(freqLW, ict) * ones(1,9);
  rLWSP = bt2rad(freqLW, spt) * ones(1,9);

  rMWIT = bt2rad(freqMW, ict) * ones(1,9);
  rMWSP = bt2rad(freqMW, spt) * ones(1,9);

  rSWIT = bt2rad(freqSW, ict) * ones(1,9);
  rSWSP = bt2rad(freqSW, spt) * ones(1,9);

  % initialize output arrays
  rLW = zeros(nchLW, 9, 30, nswath);
  rMW = zeros(nchMW, 9, 30, nswath);
  rSW = zeros(nchSW, 9, 30, nswath);
 
  for i = 1 : nswath   % loop on swaths
    for j  = 1 : 30    % loop on ES

      rLW(:,:,j,i) = rLWIT - (avgLWIT(:,:,1,i) - swLW(:,:,j,i)) .* ...
                 (rLWIT - rLWSP) ./ (avgLWIT(:,:,1,i) -  avgLWSP(:,:,1,i)); 

      rMW(:,:,j,i) = rMWIT - (avgMWIT(:,:,1,i) - swMW(:,:,j,i)) .* ...
                 (rMWIT - rMWSP) ./ (avgMWIT(:,:,1,i) -  avgMWSP(:,:,1,i)); 

      rSW(:,:,j,i) = rSWIT - (avgSWIT(:,:,1,i) - swSW(:,:,j,i)) .* ...
                 (rSWIT - rSWSP) ./ (avgSWIT(:,:,1,i) -  avgSWSP(:,:,1,i)); 
    end
  end  

  % ----------------
  % plots and images
  % ----------------

  % note for raw images: data is in column order and time order.
  % in general we want the transpose of this, so rows/ES run E/W 
  % and swaths N/S.

% % basic 1-FOV 1-freq image
% img1 = squeeze(real(rLW(400,5,:,:)));
% imagesc(img1')

% % all FOVs, 1-freq, need to get FOV tiling right
% img2 = zeros(90,3*nswath);
% for i = 1 : nswath
%   for j = 1 : 30
%     tt = reshape(squeeze(real(rLW(400,:,j,i))), 3, 3);
%     ix = 3*(j-1)+1;
%     iy = 3*(i-1)+1;
%     img2(ix:ix+2, iy:iy+2) = tt;
%   end
% end
% imagesc(img2')
% pause(1)

% % quick check to compare versions
% sum(real(rLW(~isnan(rLW(:)))))

end

