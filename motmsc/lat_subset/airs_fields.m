
adir = '/asl/data/airs/L1C/2016/126';
agran = 'AIRS.2016.05.05.231.L1C.AIRS_Rad.v6.1.2.0.G16127122356.hdf';
afile = fullfile(adir, agran);

xx = hdfinfo(afile);

% first group
% 
% Time
% Longitude
% Latitude
% LandFrac
%

for i = 1 : 3
  xx.Vgroup.Vgroup(1).SDS(i)
end

% second group

for i = 1 : 27
  xx.Vgroup.Vgroup(2).SDS(i)
end

