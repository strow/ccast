%
% NAME
%   calmain_nedn - mod to dump ICT and SP looks
%
% SYNOPSIS
%   [rcal, vcal, nedn] = ...
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
%   nedn    - nchan x 2 NEdN estimates
%
% DISCUSSION
%   The calibration equation is
%
%     r_obs = F * r_ict * f * SA-1 * f * (ES-SP)/(ICT-SP)
%
%   r_obs - calibrated radiance at the user grid
%   F     - fourier interpolation to the user grid
%   r_ict - expected ICT radiance at the sensor grid
%   f     - raised-cosine bandpass filter
%   SA-1  - inverse of the ILS matrix
%   ES    - earth-scene count spectra
%   IT    - calibration target count spectra
%   SP    - space-look count spectra
%
% AUTHOR
%   H. Motteler, 26 Apr 2012
%

function [avgnSP, avgnIT, obsnIT, t_IT, r_IT, Sinv] = ...
   calmain_nedn(inst, user, rcnt, stime, avgIT, avgSP, sci, eng, geo, opts)

%-------------------
% calibration setup
%-------------------

% get the spectral space numeric filter
inst.sNF = specNF(inst, opts.NF_file);

% get key dimensions
[nchan, n, k, nscan] = size(rcnt);

% initialize the output array
rcal = ones(nchan, 9, 30, nscan) * NaN;

% NEdN setup
avgnSP = ones(nchan, 9, 2, nscan) * NaN;
avgnIT = ones(nchan, 9, 2, nscan) * NaN;
obsnIT = ones(nchan, 9, 2, nscan) * NaN;
t_IT = ones(nscan) * NaN;
r_IT = ones(nchan, nscan);

% select band-specific options
switch inst.band
  case 'LW', sfile = opts.LW_sfile;
  case 'MW', sfile = opts.MW_sfile;
  case 'SW', sfile = opts.SW_sfile;
end

% get the SA inverse matrix
Sinv = getSAinv(sfile, inst);

% get processing filter specs
pL = inst.pL; pH = inst.pH; rL = inst.rL; rH = inst.rH;

% build the resampling matrix
[R, vcal] = resamp(inst, user, opts.resamp);

%---------------
% loop on scans
%---------------

for si = 1 : nscan 
 
  % check that this row has some ES's
  if isnan(max(stime(1:30, si)))
    continue
  end

  % get index of the closest sci record
  dt = abs(max(stime(:, si)) - [sci.time]);
  ix = find(dt == min(dt));

  % get ICT temperature
  T_ICT = (sci(ix).T_PRT1 + sci(ix).T_PRT2) / 2;

  % get expected ICT radiance at the sensor grid
  B = ICTradModel(inst.band, inst.freq, T_ICT, sci(ix), eng.ICT_Param, ...
                  1, NaN, 1, NaN);

  % save for nedn tabulation
  t_IT(si) = T_ICT;
  r_IT(:, si) = B.total(:);

  % apply nonlinearity correction, SP=31:32, IT=33:34
  for j = 1 : 2
    avgnSP(:,:,j,si) = nlc_vec(inst, avgSP(:,:,j,si), avgSP(:,:,j,si), eng);
    avgnIT(:,:,j,si) = nlc_vec(inst, avgIT(:,:,j,si), avgSP(:,:,j,si), eng);
    obsnIT(:,:,j,si) = nlc_vec(inst, rcnt(:,:,j+32,si), avgSP(:,:,j,si), eng);
  end

end

