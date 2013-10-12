%
% place-holder for high-res non-linearity correction
%

function [nlcorr_cxs, extra] = ...
    nlc(band, iFov, v, scene_cxs, space_cxs, PGA_Gain, control)

if strcmp(upper(band), 'LW')
  [nlcorr_cxs, extra] = ...
    nlc_lowres(band, iFov, v, scene_cxs, space_cxs, PGA_Gain, control);
else
  nlcorr_cxs = scene_cxs;
  extra = struct;
end

