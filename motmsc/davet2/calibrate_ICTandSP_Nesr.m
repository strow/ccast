
%
% calibrate_ICTandSP_Nesr.m -- calibrate ICT and Space views within an 
% rcris h5 file using a fixed responsivity and then estimate Nesr
%

%
% non nonlinearity correction, no spectral processing
%
% Revisions:
%   A simplified/appended version of UMBC's rdr2spec4.m
%   DCT 19 Nov 2011.
%

echo on

addpath from_rdr2spec4_2011118/

% MIT matlab RDR data directory
dmit = '../06mit';
lmit = dir(sprintf('%s/RDR*.mat', dmit));

% initialize sci and eng packet struct's
eng1 = struct([]);
allsci = struct([]);

% -------------------------
% loop on MIT RDR mat files
% -------------------------

%for fi = 71 : 80
for fi = 78
 
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

  % RDR validation.  checkRDR returns data as a nchan x 9 x nobs
  % arrays, ordered by time
  [igmLW, igmMW, igmSW, igmTime, igmFOR] = checkRDR4f(d1, rid);

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
                 scanorder(rcLW, rcMW, rcSW, igmTime, igmFOR, rid);

  [m, n, k, nscan] = size(scLW);

  clear rcLW rcMW rcSW

  % -------------------------------------------------
  % Extract ICT and SP views 
  % -------------------------------------------------

  LWSP = scLW(:, :, 31:32, :);
  LWIT = scLW(:, :, 33:34, :);
  MWSP = scMW(:, :, 31:32, :);
  MWIT = scMW(:, :, 33:34, :);
  SWSP = scSW(:, :, 31:32, :);
  SWIT = scSW(:, :, 33:34, :);

  % -------------------------------------------------
  % Compute blackbody radiance for ICT temp (No need for full ICT rad model)
  % -------------------------------------------------
  iSci = 1;  % Use params from First 8-sec-sci packet
  T_ICT = (sci(iSci).T_PRT1 + sci(iSci).T_PRT2) / 2;
  Blw = bt2rad(freqLW,T_ICT); 
  Bmw = bt2rad(freqMW,T_ICT); 
  Bsw = bt2rad(freqSW,T_ICT); 

  % -------------------------------------------------
  % Compute mean ICT and SP complex spectra
  % -------------------------------------------------
  meanLWSP = mean(LWSP,4);  
  meanLWIT = mean(LWIT,4);  
  meanMWSP = mean(MWSP,4);  
  meanMWIT = mean(MWIT,4);  
  meanSWSP = mean(SWSP,4);  
  meanSWIT = mean(SWIT,4);  

  % ----------------------------------------------
  % Radiometric calibration using fixed responsivity
  % ----------------------------------------------
  calLWIT = zeros(nchLW,9,2,nscan);
  calLWSP = zeros(nchLW,9,2,nscan);
  calMWIT = zeros(nchMW,9,2,nscan);
  calMWSP = zeros(nchMW,9,2,nscan);
  calSWIT = zeros(nchSW,9,2,nscan);
  calSWSP = zeros(nchSW,9,2,nscan);

  for iFov = 1:9
    for iSweep = 1:2
      for iScan = 1:nscan
        calLWIT(:,iFov,iSweep,iScan) = (LWIT(:,iFov,iSweep,iScan) - meanLWSP(:,iFov,iSweep)) ./ ...
		                           (meanLWIT(:,iFov,iSweep)-meanLWSP(:,iFov,iSweep)).*Blw;
        calMWIT(:,iFov,iSweep,iScan) = (MWIT(:,iFov,iSweep,iScan) - meanMWSP(:,iFov,iSweep)) ./ ...
		                           (meanMWIT(:,iFov,iSweep)-meanMWSP(:,iFov,iSweep)).*Bmw;
        calSWIT(:,iFov,iSweep,iScan) = (SWIT(:,iFov,iSweep,iScan) - meanSWSP(:,iFov,iSweep)) ./ ...
		                           (meanSWIT(:,iFov,iSweep)-meanSWSP(:,iFov,iSweep)).*Bsw;
        calLWSP(:,iFov,iSweep,iScan) = (LWSP(:,iFov,iSweep,iScan) - meanLWSP(:,iFov,iSweep)) ./ ...
		                           (meanLWIT(:,iFov,iSweep)-meanLWSP(:,iFov,iSweep)).*Blw;
        calMWSP(:,iFov,iSweep,iScan) = (MWSP(:,iFov,iSweep,iScan) - meanMWSP(:,iFov,iSweep)) ./ ...
		                           (meanMWIT(:,iFov,iSweep)-meanMWSP(:,iFov,iSweep)).*Bmw;
        calSWSP(:,iFov,iSweep,iScan) = (SWSP(:,iFov,iSweep,iScan) - meanSWSP(:,iFov,iSweep)) ./ ...
		                           (meanSWIT(:,iFov,iSweep)-meanSWSP(:,iFov,iSweep)).*Bsw;
      end
    end
  end
  

  % -------------------------------------------------
  % Estimate noise from calibrated space views
  % -------------------------------------------------
  % Can combine sweep directions, or not
  % If needed, manually exclude some scan lines from the ensemble
  keepScans = (1:nscan)';
  keepScans = setdiff(keepScans,12);
  for iFov = 1:9
    nesr_space_lw1(:,iFov) = std(real(calLWSP(:,iFov,1,keepScans)),0,4);
    nesr_space_lw2(:,iFov) = std(real(calLWSP(:,iFov,2,keepScans)),0,4);
    nesr_space_mw1(:,iFov) = std(real(calMWSP(:,iFov,1,keepScans)),0,4);
    nesr_space_mw2(:,iFov) = std(real(calMWSP(:,iFov,2,keepScans)),0,4);
    nesr_space_sw1(:,iFov) = std(real(calSWSP(:,iFov,1,keepScans)),0,4);
    nesr_space_sw2(:,iFov) = std(real(calSWSP(:,iFov,2,keepScans)),0,4);
  end

  % -------------------------------------------------
  % Compute ICT blackbody radiance for each scan line, since ICT temp may drift
  % -------------------------------------------------
  predLWIT = zeros(nchLW,nscan);
  predMWIT = zeros(nchMW,nscan);
  predSWIT = zeros(nchSW,nscan);
  for iScan = 1:nscan
    T_ICT = (sci(iScan).T_PRT1 + sci(iScan).T_PRT2) / 2;    
    predLWIT(:,iScan) = bt2rad(freqLW,T_ICT);
    predMWIT(:,iScan) = bt2rad(freqMW,T_ICT);
    predSWIT(:,iScan) = bt2rad(freqSW,T_ICT);
  end

  % And compute differences between calibrated and predicted ICT for each scan line
  diffLWIT = calLWIT*0;
  diffMWIT = calMWIT*0;
  diffSWIT = calSWIT*0;
  for iFov = 1:9
    for iSweep = 1:2
      for iScan = 1:nscan
        diffLWIT(:,iFov,iSweep,iScan) = calLWIT(:,iFov,iSweep,iScan) - predLWIT(:,iScan);
        diffMWIT(:,iFov,iSweep,iScan) = calMWIT(:,iFov,iSweep,iScan) - predMWIT(:,iScan);
        diffSWIT(:,iFov,iSweep,iScan) = calSWIT(:,iFov,iSweep,iScan) - predSWIT(:,iScan);
      end
    end
  end

  % -------------------------------------------------
  % Estimate noise from calibrated ICT views
  % -------------------------------------------------
  % Can combine sweep directions, or not
  % If needed, manually exclude some scan lines from the ensemble
  keepScans = (1:nscan)';
  keepScans = setdiff(keepScans,12);

  %  x = real(diffLWIT(:,:,:,keepScans));
  %  plot(x(:,:))
  
  for iFov = 1:9
    nesr_ict_lw1(:,iFov) = std(real(diffLWIT(:,iFov,1,keepScans)),0,4);
    nesr_ict_lw2(:,iFov) = std(real(diffLWIT(:,iFov,2,keepScans)),0,4);
    nesr_ict_mw1(:,iFov) = std(real(diffMWIT(:,iFov,1,keepScans)),0,4);
    nesr_ict_mw2(:,iFov) = std(real(diffMWIT(:,iFov,2,keepScans)),0,4);
    nesr_ict_sw1(:,iFov) = std(real(diffSWIT(:,iFov,1,keepScans)),0,4);
    nesr_ict_sw2(:,iFov) = std(real(diffSWIT(:,iFov,2,keepScans)),0,4);
  end

  clf
  plot(freqLW,nesr_space_lw1,'b',freqMW,nesr_space_mw1,'b',freqSW,nesr_space_sw1,'b')
  hold on
  plot(freqLW,nesr_ict_lw1,'r',freqMW,nesr_ict_mw1,'r',freqSW,nesr_ict_sw1,'r')      
  set(gca,'YScale','log')
  xlabel('wavenumber')
  ylabel('NESR')
  axis([600 2620 1E-3 1]);grid
  h = title(fmit);set(h,'interp','none')
  drawnow



  % Also add noiseMaker.m to separate spectrally correlated and 
  % uncorrelated noise components for both SP and IT views 
 



end



