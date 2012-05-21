%
% NAME
%   read_GCRSO - read a CrIS GCRSO (geo) file
%
% SYNOPSIS
%   geo = read_GCRSO(gfile)
%
% INPUT
%   gfile  - h5 GCRSO filename
%
% OUTPUT
%   geo  - struct with GCRSO data fields and selected attributes
%
% DISCUSSION
%   this version uses the new h5 calls.  it sets h5 group paths and
%   fields explicitly to avoid a call to h5info, which is very slow.
%
% AUTHOR
%   H. Motteler, 8 May 2012
%

function geo = read_GCRSO(gfile)

geo = struct;

% info = h5info(gfile);
% nfields = length(info.Groups(1).Groups.Datasets);
% dpath =info.Groups(1).Groups.Name;

nfields = 16;
dpath = '/All_Data/CrIS-SDR-GEO_All';

dname{1} = 'FORTime';
dname{2} = 'Height';
dname{3} = 'Latitude';
dname{4} = 'Longitude';
dname{5} = 'MidTime';
dname{6} = 'PadByte1';
dname{7} = 'QF1_CRISSDRGEO';
dname{8} = 'SCAttitude';
dname{9} = 'SCPosition';
dname{10} = 'SCVelocity';
dname{11} = 'SatelliteAzimuthAngle';
dname{12} = 'SatelliteRange';
dname{13} = 'SatelliteZenithAngle';
dname{14} = 'SolarAzimuthAngle';
dname{15} = 'SolarZenithAngle';
dname{16} = 'StartTime';

for ix = 1 : nfields

  % dname = info.Groups(1).Groups.Datasets(ix).Name;
  % dval = h5read(gfile, [dpath, '/', dname]);
  % eval(sprintf('geo.%s = dval;', dname));

  dval = h5read(gfile, [dpath, '/', dname{ix}]);
  geo = setfield(geo, dname{ix}, dval);

end

