%
% fovdiff -- max RMS FOV difference
%

function d = fovdiff(b);

d = 0;
for i = 1 : 8
 for j = i+1 : 9
   t = rms(b(:,i) - b(:,j));
   if t > d, d = t; end
 end
end

