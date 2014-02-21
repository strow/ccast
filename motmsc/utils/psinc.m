
function y = psinc(x, n)

if x == 0
  y = 0;
else
  y = sin(x) ./ (n * sin(x/n));
end


