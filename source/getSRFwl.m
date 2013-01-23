%
% NAME
%   getSRFwl  -  wlaser SRF matrix interpolation
%
% SYNOPSIS
%   function [smat, vobs] = getSRFwl(wlaser, sfile)
%
% INPUTS
%   wlaser  - metrology laser wavelength
%   sfile   - file of SRF matrices tabulated by wlaser
%
% OUTPUTS
%   smat    - interpolated srf matrix
%   vobs    - interpolated frequency grid
%
% NOTES
%   sfile contains a structure array with fields
%     s().stab    - tabulated srf matrix
%     s().wlaser  - corresponding wlaser values
%     s().vobs    - corresponding frequency scale
%
%   this version does linear interpolation
%
%   an interpolated value for vobs is returned but the
%   directly calculated value would normally be preferable
%

function [smat, vobs] = getSRFwl(wlaser, sfile)

% load the SRF table
load(sfile);
ntab = length(s);

% copy wlaser values to a vector
wtab = zeros(ntab,1);
for i = 1 : ntab
  wtab(i) = s(i).wlaser;
end

% find position of wlaser in the table
wj = max(find(wtab <= wlaser));
if isempty(wj)
  wj = 1;
elseif wj == ntab
  wj = wj - 1;
end

% get the interpolation weights
w = wlaser;
w1 = wtab(wj);
w2 = wtab(wj+1);
aw = (w2 - w)/(w2 - w1);
bw = (w - w1)/(w2 - w1);

% do the interpolation
smat = aw * s(wj).stab + bw * s(wj+1).stab;
vobs = aw * s(wj).vobs + bw * s(wj+1).vobs;

