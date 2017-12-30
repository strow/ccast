
function [y2, d2] = prev_doy(y1, d1)

if d1 > 1
  d2 = d1 - 1;
  y2 = y1;
elseif d1 == 1
  y2 = y1 - 1;
  d2 = datenum([y1, 1, 1]) - datenum([y2, 1, 1])
else
  error('bad value for d1')
end

