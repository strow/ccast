%
% NAME
%   get_npole_xing - north pole crossing time from L1a data
%
% SYNOPSIS
%   npole_xing = get_npole_xing(flist);
%
% INPUT
%   flist - matlab dir list of L1a filenames and paths
%
% OUTPUT
%   npole_xing - north pole crossing time, TAI
%

function npole_xing = get_npole_xing(flist);

% FOV and FOR indices, used for validation
iFOV = 5;
iFOR = 16;

% loop on CrIS granules until we get a north polar crossing
done = false;
xing_list = [];
npole_xing = NaN;
for fi = 1 : length(flist);
  cfile = fullfile(flist(fi).folder, flist(fi).name);
  d1 = load(cfile, 'scGeo');

  tai = iet2tai(d1.scGeo.FORTime(iFOR,:))';
  asc = d1.scGeo.Asc_Desc_Flag;

  lat = squeeze(d1.scGeo.Latitude(iFOV,iFOR,:));
  lon = squeeze(d1.scGeo.Longitude(iFOV,iFOR,:));

  gOK = -90 <= lat & lat <=  90 & ...
       -180 <= lon & lon <= 180 & ...
       ~isnan(asc);

  lat = lat(gOK);
  tai = tai(gOK);
  asc = asc(gOK);

  for i = 2 : length(asc);
    dt = tai(i) - tai(i-1);
    if asc(i-1) == 0 && asc(i) == 1 && abs(dt - 8) < 0.1
      npole_xing = tai(i-1);
%     [fi, i, lat(i), lat(i-1)]
%     xing_list = [xing_list, npole_xing];
      done = true;
      break
    end
  end
  if done, break, end
end

% diff(xing_list)

if ~isnan(npole_xing)
  fprintf(1, 'N. pole crossing time %s\n', datestr(tai2dnum(npole_xing)));
else
  error('could not get north pole crossing time')
end

