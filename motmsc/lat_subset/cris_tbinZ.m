%
% cris_tbin - CrIS Tb bins with lat and ocean subsetting
%

addpath ../source

% year and path to data
  ayear = '/asl/data/cris/ccast/sdr60_hr/2016';
% ayear = '/asl/data/cris/ccast/sdr60_hr/2017';

% specify days of the year
dlist = 274 : 364;  % Z fall

% specify FORs
% iFOR = 15 : 16;       % 1 near nadir
  iFOR =  1 : 30;       % 2 full scan
% iFOR = [8 15 16 23];  % 3 near nadir plus half scan
% iFOR = [8 23];        % 4 half scan only
% iFOR = 13 : 18;       % 5 expanded nadir
nFOR = length(iFOR);

% freq span for Tb
  v1 =  899; v2 =  904;
% v1 = 2450; v2 = 2550;

% initialize bins
dT = 0.25;
T1 = 200;  T2 = 340;
tind = T1 : dT : T2;
nbin = length(tind);
tbin = zeros(nbin, 1);

% loop on days of the year
for di = dlist
  
  % loop on L1c granules
  doy = sprintf('%03d', di);
  flist = dir(fullfile(ayear, doy, 'SDR*.mat'));

  for fi = 1 : length(flist);

    afile = fullfile(ayear, doy, flist(fi).name);

%   % load everyting for local L1b_err calc
%   d1 = load(afile);

%   % just load LW radiances
    d1 = load(afile, 'vLW', 'rLW', 'L1b_err', 'geo');
    ixv = find(v1 <= d1.vLW & d1.vLW <=v2);
    rad = d1.rLW(ixv,:,iFOR,:);
    frq = d1.vLW(ixv);

%   % just load SW radiances
%   d1 = load(afile, 'vSW', 'rSW', 'L1b_err');
%   ixv = find(v1 <= d1.vSW & d1.vSW <=v2);
%   rad = d1.rSW(ixv,:,iFOR,:);
%   frq = d1.vSW(ixv);

%  % new L1b_err local calc
%   L1b_err = ...
%      checkSDR(d1.vLW, d1.vMW, d1.vSW, d1.rLW, d1.rMW, d1.rSW, ...
%               d1.cLW, d1.cMW, d1.cSW, d1.L1a_err, d1.rid);
%   iOK = ~L1b_err(:,iFOR,:);
%   rad = rad(:,iOK);

    % new L1b_err from file
    iOK = ~d1.L1b_err(:,iFOR,:);
    rad = rad(:,iOK);

    % read lat and lon
    lat = d1.geo.Latitude(:,iFOR,:);
    lon = d1.geo.Longitude(:,iFOR,:);
    lat = lat(iOK);
    lon = lon(iOK);

    % latitude subsample
    lat_rad = deg2rad(lat);
    [m,n] = size(lat_rad);
    jx = rand(m, n) < abs(cos(lat_rad));
    lat = lat(jx);
    lon = lon(jx);
    rad = rad(:,jx);

    % ocean or land subset
    [~, landfrac] = usgs_deg10_dem(lat', lon');
    ocean = landfrac(:) == 0;
    rad = rad(:, ocean);
%   land = landfrac(:) == 1;
%   rad = rad(:, land);
    if isempty(rad), continue, end

    % brightness temp bins
    Tb = real(rad2bt(frq, rad));
    rmsTb = squeeze(rms(Tb));
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

save cris_tbinZ ayear dlist iFOR v1 v2 frq tind tbin

