%
% airs_tbin2 -- AIRS Tb bins with latitude subsetting
%

addpath ../source

% year and path to data
  ayear = '/asl/data/airs/L1C/2016';
% ayear = '/asl/data/airs/L1C/2017';

% specify days of the year
% dlist = 21 : 56;
% dlist =  1 : 13 : 365;  % 29 day test
% dlist = 13 : 11 : 354;  % 32 day test
% dlist = 22 :  7 : 351;  % 48 day test
  dlist = 19 :  7 : 348;  % 48 day test

% xtrack subset
ixt = 43 : 48;
nxt = length(ixt);

% freq span for Tb
  v1 =  899; v2 =  904;
% v1 = 2450; v2 = 2550;

% initialize bins
tind = 200 : 2 : 340;
nbin = length(tind);
tbin = zeros(nbin, 1);

% L1c channel frequencies
afrq = load('freq2645.txt');
ixv = find(v1 <= afrq & afrq <=v2);
afrq = afrq(ixv);

% loop on days of the year
for di = dlist
  
  % loop on L1c granules
  doy = sprintf('%03d', di);
  flist = dir(fullfile(ayear, doy, 'AIRS*L1C*.hdf'));

  for fi = 1 : length(flist);

    % selected radiance
    afile = fullfile(ayear, doy, flist(fi).name);
    rad = hdfread(afile, 'radiances');
    rad = rad(:, ixt, ixv);
    rad = permute(rad, [3,2,1]);

    % selected latitude
    lat = hdfread(afile, 'Latitude');
    lat = lat(:,ixt);
    lat = permute(lat, [2,1]);

    % basic latitude QC
    iOK = -90 <= lat & lat <= 90;

    % latitude subsample
    lat_rad = deg2rad(lat);
    jx = rand(nxt, 135) < abs(cos(lat_rad));
    jx = jx & iOK;
    lat = lat(jx);
    rad = rad(:,jx);

    % brightness temp bins
    Tb = real(rad2bt(afrq, rad));
    rmsTb = rms(Tb);
    rmsTb = rmsTb(:);

    ix = floor((rmsTb - 200) / 2);
    ix(ix < 1) = 1;
    ix(nbin < ix) = nbin;

    for i = 1 : length(ix)
      tbin(ix(i)) = tbin(ix(i)) + 1;
    end

    if mod(fi, 10) == 0, fprintf(1, '.'), end
  end
  fprintf(1, '\n')
end

clear rtmp
save airs_tbin

