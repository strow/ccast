%
% NAME
%   calmain - wrapper to select a calibration algorithm
%
% SYNOPSIS
%   [rcal, vcal, nedn] = ...
%      calmain(inst, user, rcnt, stime, avgIT, avgSP, sci, eng, geo, opts);
%
% DISCUSSION
%   uses opts.cal_fun to specify the calibration algorithm
%

function [rcal, vcal, nedn] = ...
     calmain(inst, user, rcnt, stime, avgIT, avgSP, sci, eng, geo, opts)

switch opts.cal_fun
  case 'c0'
    [rcal, vcal, nedn] = ...
       calmain_c0(inst, user, rcnt, stime, avgIT, avgSP, sci, eng, geo, opts);
  case 'c4'
    [rcal, vcal, nedn] = ...
       calmain_c4(inst, user, rcnt, stime, avgIT, avgSP, sci, eng, geo, opts);
  case 'c5'
    [rcal, vcal, nedn] = ...
       calmain_c5(inst, user, rcnt, stime, avgIT, avgSP, sci, eng, geo, opts);
  case 'c6'
    [rcal, vcal, nedn] = ...
       calmain_c6(inst, user, rcnt, stime, avgIT, avgSP, sci, eng, geo, opts);
  case 'c7'
    [rcal, vcal, nedn] = ...
       calmain_c7(inst, user, rcnt, stime, avgIT, avgSP, sci, eng, geo, opts);
  case 'c8'
    [rcal, vcal, nedn] = ...
       calmain_c8(inst, user, rcnt, stime, avgIT, avgSP, sci, eng, geo, opts);
  case 'c9'
    [rcal, vcal, nedn] = ...
       calmain_c9(inst, user, rcnt, stime, avgIT, avgSP, sci, eng, geo, opts);
  case 'd0'
    [rcal, vcal, nedn] = ...
       calmain_d0(inst, user, rcnt, stime, avgIT, avgSP, sci, eng, geo, opts);
  case 'd1'
    [rcal, vcal, nedn] = ...
       calmain_d1(inst, user, rcnt, stime, avgIT, avgSP, sci, eng, geo, opts);
  case 'd2'
    [rcal, vcal, nedn] = ...
       calmain_d2(inst, user, rcnt, stime, avgIT, avgSP, sci, eng, geo, opts);
  otherwise
    error(sprintf('unknow calibration function %s', opts.cal_fun))
end

