%
% scancat - concatenat scan blocks from RDRs
%

function b = scancat(a1, a2)

[m1, n1] = size(a1);
[m2, n2] = size(a2);

if m1 ~= m2 
  error('row size of a1 and a2 must match)
end

% last col of a1 is all NaNs after index j
j = ntail(a1(:, n1));

if j == m1
  % no NaNs at tail of a1, concatenate a1 and a2
  c = [a1, a2];
else
  % merge the last col of a1 with first col of a2
  c = [a1(:, 1:n1-1), [a1(1:j, n1); a2(j+1:m1, 1)], a2(:, 2:n2)];
end

