
function s = seq2str(a)

if numel(a) > 1
  a = a(:);
  s = sprintf('%d-%d', a(1), a(end));
else
  s = sprintf('%d', a); end
end

