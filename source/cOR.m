%
% NAME
%   cOR -- column OR
%
% SYNOPSIS
%   B = cOR(A)
%
% INPUT
%   A  -  any logical array
%
% OUTPUTS
%   B  -  logical OR over first dimension of A
%

function B = cOR(A);

if ~islogical(A)
  error('input must be a logical array')
end

B = squeeze(sum(A) > 0);



