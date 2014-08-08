
function fb = ITTbandguards(band)

%
% function fb = cris_ITTbandguards(band)
%
% Compute ITT band guards following page 77 of ATBD Rev E.
%
% Inputs:
%  band:      'lw','mw', or 'sw'
%
% Outputs:
%  fb
%
% DCT, 23-Nov-2011
%

switch band
  case 'lw'
    c = [864 77 789 15 0.5 15 0.5];
  case 'mw'
    c = [528 49 481 22 1.0 22 1.0];
  case 'sw'
    c = [200 22 180  8 2.0  8 2.0];
end

k = (1:c(1))';
fb = (1./(exp( c(5)*(c(2)-c(4)-k) )+1)).*...
     (1./(exp( c(7)*(k-c(3)-c(6)) )+1));

