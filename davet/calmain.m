%
% NAME
%   calmain - davet main calibration procedure
%
% SYNOPSIS
%   [rcal, vcal, msc] = ...
%      calmain(inst, user, rcnt, stime, avgIT, avgSP, sci, eng, geo, opts);
%
% INPUTS
%   inst    - instrument params struct
%   user    - user grid params struct
%   rcnt    - nchan x 9 x 34 x nscan, rad counts
%   stime   - 34 x nscan, rad count times
%   avgIT   - nchan x 9 x 2 x nscan, moving avg IT rad count
%   avgSP   - nchan x 9 x 2 x nscan, moving avg SP rad count
%   sci     - struct array, data from 8-sec science packets
%   eng     - struct, most recent engineering packet
%   geo     - struct, GCRSO fields from geo_match
%   opts    - for now, everything else
%
% OUTPUTS
%   rcal    - nchan x 9 x 30 x nscan, calibrated radiance
%   vcal    - nchan x 1 frequency grid
%   msc     - optional returned parameters
%
% DISCUSSION
%   merger of bcast calmain with code from Dave and Larrabee's old
%   ccast top-level procedure and the ccast calmain2
%
%   to be interchangable with source/calmain.m, the inst and user
%   params are assumed to be set by inst_params, but the first step
%   here is to call spectral_params and use those values instead.
%
%   If opts.calmode is 1, radiometric calibration is done before self
%   apodization correction.  In this case, the ICT predicted radiance
%   is evaluated at the FOV dependent off-axis wavenumber grids and
%   the output variable R1 is the calibrated radiances and ICTrad is
%   an array of ICT predicted radiance evaluated at the off-axis
%   wavenumber grids.
%
%   If opts.calmode is 2, self apodization correction is performed
%   before radiometric calibration.  In this case, the output variable
%   R1 is the ratio of the nonlinearity corrected complex spectra
%   (Ces-Csp)/(Cit-Csp) without SA correction, and ICTrad is an array
%   of ICT predicted radiance evaluated at the on-axis sensor grid.
%
% AUTHOR
%   H. Motteler, D. Tobin, 18 June 2012
%

function [rcal, vcal, msc] = ...
     calmain(inst, user, rcnt, stime, avgIT, avgSP, sci, eng, geo, opts)

% use Dave's sensor and user grid parameters here
[user2, sensor] = spectral_params(lower(inst.band), inst.wlaser);

% load parameters for nlc()
control = load(opts.DClevel_file);
control.NF = load(opts.cris_NF_file);
control.NF = control.NF.NF;

% get key dimensions
[nchan, n, k, nscan] = size(rcnt);

% initialize the output array
% rcal = ones(nchan, 9, 30, nscan) * NaN;
rtmp = ones(nchan, 9, 30, nscan) * NaN;
rICT = ones(nchan, 9, nscan) * NaN;

% initialize working arrays
es_nlc = ones(nchan, 1) * NaN;
sp_nlc = ones(nchan, 2) * NaN;
it_nlc = ones(nchan, 2) * NaN;

% select band-specific options
switch inst.band
  case 'LW'
    bopt = opts.LW;
    bisa = opts.isa.lw;
  case 'MW'
    bopt = opts.MW;
    bisa = opts.isa.mw;
  case 'SW'
    bopt = opts.SW;
    bisa = opts.isa.sw;
end

for si = 1 : nscan   % loop on scans
 
  % check that this row has some ES's
  if isnan(max(stime(1:30, si)))
    continue
  end

  % get index of the closest sci record, 
  dt = abs(max(stime(:, si)) - [sci.time]);
  ix = find(dt == min(dt));

  % compute ICT temperature
  T_ICT = (sci(ix).T_PRT1 + sci(ix).T_PRT2) / 2;

  for iFov = 1 : 9  % loop on FOVs

    % wavenumbers for ICT radiance calculation
    if opts.calmode == 1;      wnbr = sensor.v_offaxis(:,iFov);
    elseif opts.calmode == 2;  wnbr = sensor.v_onaxis;
    end

    % Compute ICT predicted radiance
    B = ICTradModel(sensor.band, wnbr, ...
               T_ICT, sci(ix), eng.ICT_Param, 1, NaN, 1, NaN);
    rICT(:, iFov, si) = B.total;

    for k = 1 : 2   % loop on sweep directions
 
      % do the ICT and space look nonlinearity corrections
      [sp_nlc(:, k), extra] = nlc(sensor.band, iFov, sensor.v_onaxis, ...
                                  avgSP(:, iFov, k, si), ...
                                  avgSP(:, iFov, k, si), ...
                                  eng.PGA_Gain, control);   

      [it_nlc(:, k), extra] = nlc(sensor.band, iFov, sensor.v_onaxis, ...
                                  avgIT(:, iFov, k, si), ...
                                  avgSP(:, iFov, k, si), ...
                                  eng.PGA_Gain, control);   
    end    

    for iES = 1 : 30  % loop on ES

      % match ES and cal sweep directions.  The ES and cal indices
      % have opposite parity for real instrument (vs 2010 test) data
%     k = 2 - mod(iES, 2);  % same parity for 2010 proxy data
      k = mod(iES, 2) + 1;  % opposite parity for all real data

      % do the ES nonlinearity correction
      [es_nlc, extra] = nlc(sensor.band, iFov, sensor.v_onaxis, ...
                            rcnt(:, iFov, iES, si), ...
                            avgSP(:, iFov, k, si), ...
                            eng.PGA_Gain, control);   

      % calculate (ES-SP)/(ICT-SP), accounting for sweep direction
      rtmp(:, iFov, iES, si) = ...
              (es_nlc - sp_nlc(:,k)) ./ (it_nlc(:,k) - sp_nlc(:,k));

      % option to do the radiometric calibration before SA inv
      if opts.calmode == 1
        rtmp(:, iFov, iES, si) = rtmp(:, iFov, iES, si) .* B.total;
      end

    end     % loop on ES
  end       % loop on FOVs
end % loop on scans

% apply the bandpass and SA-1 transforms
% note: the scan dimension could be dropped from the following and
% they could be pulled into the scan loop for some memory savings and
% a possible speedup--that's how source/calmain.m works.  but for now
% this works well enough

itmp = imag(rtmp);

rtmp = applyITTbandguards(real(rtmp), sensor);

rtmp = selfApodCorr(rtmp, bisa);

rtmp = applyITTbandguards(real(rtmp), sensor);

if opts.calmode == 2
  rtmp = radcal(rtmp, rICT);
  itmp = radcal(itmp, rICT);
end

rtmp = applyResampling(rtmp, user2, sensor, opts.resample_mode);

vcal = user2.v;
rcal = rtmp;
msc = struct;

