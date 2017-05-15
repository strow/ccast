%
% NAME
%   cAND -- column AND
%
% SYNOPSIS
%   B = cAND(A)
%
% INPUT
%   A  -  any logical array
%
% OUTPUTS
%   B  -  logical AND over first dimension of A
%

function B = cAND(A);

if ~islogical(A)
  error('input must be a logical array')
end

B = squeeze(prod(A) > 0);

