%
% NAME
%   calmain - wrapper to select a calibration algorithm
%
% SYNOPSIS
%   [rcal, vcal, nedn] = ...
%      calmain(inst, user, rcnt, avgIT, avgSP, sci, eng, geo, opts);
%
% DISCUSSION
%   uses opts.cal_fun to specify the calibration algorithm; see the
%   individual functions for details and source/REAME for an overview
%

function [rcal, vcal, nedn] = ...
          calmain(inst, user, rcnt, avgIT, avgSP, sci, eng, geo, opts)

switch opts.cal_fun
  case 'a4'
    [rcal, vcal, nedn] = ...
       calmain_a4(inst, user, rcnt, avgIT, avgSP, sci, eng, geo, opts);
  case 'c5'
    [rcal, vcal, nedn] = ...
       calmain_c5(inst, user, rcnt, avgIT, avgSP, sci, eng, geo, opts);
  case 'c6'
    [rcal, vcal, nedn] = ...
       calmain_c6(inst, user, rcnt, avgIT, avgSP, sci, eng, geo, opts);
  case 'c7'
    [rcal, vcal, nedn] = ...
       calmain_c7(inst, user, rcnt, avgIT, avgSP, sci, eng, geo, opts);
  case 't1'
    [rcal, vcal, nedn] = ...
       calmain_t1(inst, user, rcnt, avgIT, avgSP, sci, eng, geo, opts);
  case 't2'
    [rcal, vcal, nedn] = ...
       calmain_t2(inst, user, rcnt, avgIT, avgSP, sci, eng, geo, opts);
  otherwise
    error(sprintf('unknow calibration function %s', opts.cal_fun))
end

