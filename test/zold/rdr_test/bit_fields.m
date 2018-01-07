
function values = bit_fields(fields, word)

n = length(fields);
values = zeros(n, 1);
mask = 2^fields(1) - 1;
values(1) = bitand(word, mask);

for i = 2 : length(fields)
  word = bitshift(word, -fields(i-1));
  mask = 2^fields(i) - 1;
  values(i) = bitand(word, mask);
end


