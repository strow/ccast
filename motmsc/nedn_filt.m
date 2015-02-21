%
% NAME
%   nedn_filt -- principle component filter for NEdN data
%
% SYNOPSIS
%   nedn2 = nedn_filt(user, filt, vcal, nedn1)
%
% INPUTS
%   user   -  user grid struct
%   filt   -  NEdN filter mat file
%   vcal   -  nchan vector of frequencies
%   nedn1  -  nchan x 9 x 2 input NEdN data
%   
% OUTPUT
%   nedn2  -  nchan x 9 x 2 filtered NEdN data
%
% DISCUSSION
%
% AUTHOR
%  H. Motteler, 15 Feb 2015
%

function nedn2 = nedn_filt(user, filt, vcal, nedn1)

load(filt)

switch upper(user.band)
  case 'LW', u = uLW; vfilt = vLW;
  case 'MW', u = uMW; vfilt = vMW; 
  case 'SW', u = uSW; vfilt = vSW;
end

% match user grid to filter grid
[ix, jx] = seq_match(vcal, vfilt);

% initialize output
nedn2 = nedn1;

% apply the filter 
for si = 1 : 2
  for fi = 1 : 9
    nedn2(ix,fi,si) = ...
      u(jx,:,fi,si) * (u(jx,:,fi,si)' * nedn1(ix, fi, si));
  end
end

