%
% airs_tbin - AIRS Tb bins with lat and ocean subsetting
%

addpath ../source

% year and path to data
  ayear = '/asl/data/airs/L1C/2016';
% ayear = '/asl/data/airs/L1C/2017';

% specify days of the year
dlist =   1 :  91;  % W winter

% xtrack subset
% ixt = 43 : 48;              % 1 near nadir
  ixt =  1 : 90;              % 2 full scan
% ixt = [21:23 43:48 68:70];  % 3 near nadir plus half scan
% ixt = [21:23 68:70];        % 4 half scan only
% ixt = 37 : 54;              % 5 expanded nadir
nxt = length(ixt);

% freq span for Tb
  v1 =  899; v2 =  904; nedn = 0.2;
% v1 = 2450; v2 = 2550;

% initialize bins
dT = 0.25;
T1 = 200;  T2 = 340;
tind = T1 : dT : T2;
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

    % radiance channel and xtrack subset
    afile = fullfile(ayear, doy, flist(fi).name);
    rad = hdfread(afile, 'radiances');
    rad = rad(:, ixt, ixv);
    rad = permute(rad, [3,2,1]);

    % latitude xtrack subset
    lat = hdfread(afile, 'Latitude');
    lat = lat(:,ixt);
    lat = permute(lat, [2,1]);

    % longitude xtrack subset
    lon = hdfread(afile, 'Longitude');
    lon = lon(:,ixt);
    lon = permute(lon, [2,1]);

    % basic latitude QC
    iOK = -90 <= lat & lat <= 90;

    % latitude subsample
    lat_rad = deg2rad(lat);
    jx = rand(nxt, 135) < abs(cos(lat_rad));
    jx = jx & iOK;

    % apply subsetting
    rad = rad(:,jx);
    lat = lat(jx);
    lon = lon(jx);

    [~, landfrac] = usgs_deg10_dem(lat', lon');
    ocean = landfrac == 0;
    rad = rad(:, ocean);
%   land = landfrac == 1;
%   rad = rad(:, land);
    if isempty(rad), continue, end

    % add noise to smooth discretization
    [m,n] = size(rad);
    rad = rad + randn(m,n) * nedn;

    % brightness temp bins
    Tb = real(rad2bt(afrq, rad));
    rmsTb = rms(Tb);
    rmsTb = rmsTb(:);

    ix = floor((rmsTb - T1) / dT) + 1;
    ix(ix < 1) = 1;
    ix(nbin < ix) = nbin;

    for i = 1 : length(ix)
      tbin(ix(i)) = tbin(ix(i)) + 1;
    end

    if mod(fi, 10) == 0, fprintf(1, '.'), end
  end
  fprintf(1, '\n')
end

save airs_tbinW ayear dlist ixt v1 v2 afrq tind tbin

