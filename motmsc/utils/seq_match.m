%
% NAME
%  seq_match - return closest matching pairs from two sequences 
%
% SYNOPSIS
%  function [i, j] = seq_match(a, b, d) 
%
% INPUTS
%   a, b  - sorted input sequences
%   d     - optional max difference for matches
%
% OUTPUTS
%   i, j  - indices of matches in a and b
%
% DISCUSSION
%   Given sorted lists a and b, we match a(i) with b(j) iff a(i) is
%   the closest element in a to b(j) and b(j) is the closest element
%   in b to a(i).  If d is specified, then elements are matched only
%   if the distance is less than or equal to d.
%
% EXAMPLES
%   [i, j] = seq_match([2, 3, 4], [3.9, 4, 4.1]);
%   i == 3, j == 2
% 
%   [i, j] = seq_match([2, 3, 4], [3.2, 3.9, 4, 4.1]);
%   i == [2, 3], j == [1, 3]
%
%   a = [3.0 4.0 4.7 5.1 5.2 6.2 7.0 8.0 8.1 8.9];
%   b = [1.0 2.0 3.1 3.9 5.0 6.0 6.1 6.9];
%   [i, j] = seq_match(a, b);
%   a(i) ==  [3.0  4.0  5.1  6.2  7.0]
%   b(j) ==  [3.1  3.9  5.0  6.1  6.9]
%
%   Disjoint sequences such as 
%     a = [1 2 3] 
%     b = [4 5 6] 
%   will match max(a) with the min(b), if this is not more than d.
%
% AUTHOR
%  H. Motteler, 2 June 2013
%

function [i, j] = seq_match(a, b, d)

% indices in a of values closest to elements of b
ia = interp1(a, 1:length(a), b, 'nearest', 'extrap');

% indices in b of values closest to elements of a
ib = interp1(b, 1:length(b), a, 'nearest', 'extrap');

% drop duplicates
i = unique(ia(ib));
j = unique(ib(ia));
% [a(i); b(j)]

% drop matches greater than d
if nargin == 3
  iok = find(abs(a(i) - b(j)) <= d);
  i = i(iok);
  j = j(iok);
% [a(i); b(j)]
end

