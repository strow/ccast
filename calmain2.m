%
% NAME
%   calmain2 - main calibration procedure
%
% SYNOPSIS
%   [rcal, vcal, msc] = ...
%      calmain2(band, vinst, rcnt, stime, avgIT, avgSP, sci, eng, opt);
%
% INPUTS
%   band    - 'lw', 'mw', or 'sw'
%   vinst   - nchan x 1 frequency grid, 
%   rcnt    - nchan x 9 x 34 x nscan, rad counts
%   stime   - 34 x nscan, rad count times
%   avgIT   - nchan x 9 x 2 x nscan, moving avg IT rad count
%   avgSP   - nchan x 9 x 2 x nscan, moving avg SP rad count
%   sci     - struct array, data from 8-sec science packets
%   eng     - struct, most recent engineering packet
%   opt     - optional input parameters
%
% OUTPUTS
%   rcal    - nchan x 9 x 30 x nscan, calibrated radiance
%   vcal    - nchan x 1 frequency grid
%   msc     - optional returned parameters
%
% DISCUSSION
%
%  under development
%  

function [rcal, vcal, msc] = ...
     calmain2(band, vinst, rcnt, stime, avgIT, avgSP, sci, eng, opt);

% parameters for cris_nlc_CCAST()
control = load('DClevel_parameters_22July2008.mat');
control.NF = load('cris_NF_dct_20080617modified.mat');
control.NF = control.NF.NF;

% get key dimensions
[nchan, n, k, nscan] = size(rcnt);

% initialize output arrays
R1 = ones(nchan, 9, 30, nscan) * NaN;

for si = 1 : nscan   % loop on scans
 
  % check that this row has some ES's
  if isnan(max(stime(1:30, si)))
    continue
  end

  % get index of the closest sci record
  dt = abs(max(stime(:, si)) - [sci.time]);
  ix = find(dt == min(dt));

  % compute ICT temperature
  T_ICT = (sci(ix).T_PRT1 + sci(ix).T_PRT2) / 2;

  % Compute predicted radiance from ICT (on the sensor wavenumber grid)
  B = cris_ICTradModel_CCAST(band, vinst, T_ICT, ...
                             sci(ix), eng.ICT_Param, ...
                             1, NaN, 1, NaN);

  for iFov = 1 : 9  % loop on FOVs

    % apply nonlinearity correction to ICT and space views
    [sp_nlc1, extra] = ...
        cris_nlc_CCAST(band, iFov, vinst, ...
                       avgSP(:, iFov, 1, si), ...
                       avgSP(:, iFov, 1, si), ...
                       eng.PGA_Gain, control);   

    [sp_nlc2, extra] = ...
        cris_nlc_CCAST(band, iFov, vinst, ...
                       avgSP(:, iFov, 2, si), ...
                       avgSP(:, iFov, 2, si), ...
                       eng.PGA_Gain, control);   

    [it_nlc1, extra] = ...
        cris_nlc_CCAST(band, iFov, vinst, ...
                       avgIT(:, iFov, 1, si), ...
                       avgSP(:, iFov, 1, si), ...
                       eng.PGA_Gain, control);   

    [it_nlc2, extra] = ...
        cris_nlc_CCAST(band, iFov, vinst, ...
                       avgIT(:, iFov, 2, si), ...
                       avgSP(:, iFov, 2, si), ...
                       eng.PGA_Gain, control);   

    for iES = 1 : 30  % loop on ES

      % apply nonlinearity correction to each ES
      [es_nlc, extra] = ...
          cris_nlc_CCAST(band, iFov, vinst, ...
                         rcnt(:, iFov, iES, si), ...
                         avgSP(:, iFov, 1, si), ...
                         eng.PGA_Gain, control);   

      % match sweep direction and do the radiometric calibration
%     if mod(iES, 2) == 1   % for 2010 proxy data
      if mod(iES, 2) == 0   % for all real data
        R1(:, iFov, iES, si) = ...
             (es_nlc - sp_nlc1)./(it_nlc1 - sp_nlc1) .* B.total;
      else
        R1(:, iFov, iES, si) = ...
             (es_nlc - sp_nlc2)./(it_nlc2 - sp_nlc2) .* B.total;
      end
    end
  end

  % ** temporary **
  rcal = R1;
  vcal = vinst;
  msc = struct;

end

