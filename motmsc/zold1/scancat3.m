%
% scancat3 - concatenate 3 x 3 scan blocks from RDRs
%

function b = scancat3(a1, a2)

[m1, n1] = size(a1);
[m2, n2] = size(a2);

if m1 ~= m2 
  error('row size of a1 and a2 must match')
end

% last col of a1 is all NaNs after index j
j = ntail(a1(:, n1));

if j == m1
  % no NaNs at tail of a1, just concatenate a1 and a2
  b = [a1, a2];
else
  % merge the last 3 cols of a1 with first 3 cols of a2
  b = [a1(:, 1:n1-3), [a1(1:j, n1-2:n1); a2(j+1:m1, 1:3)], a2(:, 4:n2)];
end

