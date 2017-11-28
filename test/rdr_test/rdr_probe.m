%
% browse NOAA RDR info
%

p1 = '/asl/data/cris/rdr60/2016/148';
r1 = 'RCRIS-RNSCA_npp_d20160527_t2215254_e2223253_b23743_c20160528042343599711_noaa_ops.h5';

d1 = h5info(fullfile(p1, r1));

% ------------ data ------------------

d1.Groups(1)
d1.Groups(2)

d1.Groups(1).Groups(1)
d1.Groups(1).Groups(2)

for i = 1 : 15
  d1.Groups(1).Groups(1).Datasets(i)
end

for i = 1 : 15
  d1.Groups(1).Groups(1).Datasets(i).Datatype
  d1.Groups(1).Groups(1).Datasets(i).Dataspace
end

for i = 1 : 25
  d1.Groups(1).Groups(2).Datasets(i)
end

% ------------ attributes ------------------

for i = 1 : 6
  d1.Attributes(i)
end


