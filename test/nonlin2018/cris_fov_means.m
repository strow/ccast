%
% NAME
%   cris_fov_means - mean and std Tb of CrIS obs, by FOV
%
% SYNOPSIS
%   cris_fov_means(year, dlist, iFOR, dpath, sfile)
%
% INPUTS
%   year   - integer year
%   dlist  - integer day-of-year list
%   iFOR   - integer FOR list
%   dpath  - path to yyyy/doy
%   sfile  - output file
%
% OUTPUT (variables in sfile)
%   year, dlist, dpath, iFOR  - inputs
%   vLW, vMW, vSW  - channel frequencies
%   mLW, mMW, mSW  - mean brightness temps
%   sLW, sMW, sSW  - standard dev of brightness temps
%   szmean - mean satellite zenith angle 
%   nobs - obs count
%
% AUTHOR
%  H. Motteler, 22 Jan 2018
%

function cris_fov_means(year, dlist, iFOR, dpath, sfile)

% loop on days of the year
init = false;
for di = dlist
  
  % loop on CrIS granules
  doy = sprintf('%03d', di);
  ystr = sprintf('%d', year);
  fprintf(1, '%s doy %s ', ystr, doy)
  flist = dir(fullfile(dpath, ystr, doy, 'CrIS_SDR*.mat'));

  for fi = 1 : length(flist);
    if mod(fi, 10) == 0, fprintf(1, '.'), end
    cfile = fullfile(flist(fi).folder, flist(fi).name);

    % load radiances
    d1 = load(cfile,'vLW','vMW','vSW','rLW','rMW','rSW','L1b_err','geo');
    rLW = d1.rLW(:, :, iFOR, :);
    rMW = d1.rMW(:, :, iFOR, :);
    rSW = d1.rSW(:, :, iFOR, :);

    % initialize after first read
    if ~init
      vLW = d1.vLW;
      mLW = zeros(length(vLW), 9);
      wLW = zeros(length(vLW), 9);
      nLW = zeros(9, 1);

      vMW = d1.vMW;
      mMW = zeros(length(vMW), 9);
      wMW = zeros(length(vMW), 9);
      nMW = zeros(9, 1);

      vSW = d1.vSW;
      mSW = zeros(length(vSW), 9);
      wSW = zeros(length(vSW), 9);
      nSW = zeros(9, 1);

      szsum = zeros(9, 1);
      nobs = zeros(9, 1);
      init = true;
    end

    % latitude-weighted subsample
    lat_rad = deg2rad(d1.geo.Latitude(:,iFOR,:));
    [m,n,k] = size(lat_rad);
    jx = rand(m,n,k) < abs(cos(lat_rad));

    % use the L1b QC
    jx = jx & ~d1.L1b_err(:,iFOR,:);

    % loop on FOVs
    for i = 1 : 9
       ix = squeeze(jx(i,:,:));

       tLW = squeeze(rLW(:,i,:,:));
       tLW = tLW(:,ix);
       bLW = real(rad2bt(vLW, tLW));

       tMW = squeeze(rMW(:,i,:,:));
       tMW = tMW(:,ix);
       bMW = real(rad2bt(vMW, tMW));

       tSW = squeeze(rSW(:,i,:,:));
       tSW = tSW(:,ix);
       bSW = real(rad2bt(vSW, tSW));

       % loop on obs
       [~,n] = size(bLW);
       for j = 1 : n
         [mLW(:,i), wLW(:,i), nLW(i)] = ...
           rec_var(mLW(:,i), wLW(:,i), nLW(i), bLW(:,j));

         [mMW(:,i), wMW(:,i), nMW(i)] = ...
           rec_var(mMW(:,i), wMW(:,i), nMW(i), bMW(:,j));

         [mSW(:,i), wSW(:,i), nSW(i)] = ...
           rec_var(mSW(:,i), wSW(:,i), nSW(i), bSW(:,j));
       end

       ztmp = squeeze(d1.geo.SatelliteZenithAngle(i,iFOR,:));
       ztmp = ztmp(ix);
       n = length(ztmp);
       nobs(i) = nobs(i) + n;
       szsum(i) = szsum(i) + sum(ztmp);
     end

  end % loop on granules
  fprintf(1, '\n')
end % loop on days

sLW = sqrt(wLW ./ (ones(length(vLW),1) * (nLW - 1)'));
sMW = sqrt(wMW ./ (ones(length(vMW),1) * (nMW - 1)'));
sSW = sqrt(wSW ./ (ones(length(vSW),1) * (nSW - 1)'));
szmean = szsum ./ nobs;

save(sfile,'year','dlist','dpath','iFOR','vLW','vMW','vSW', ...
           'mLW','mMW','mSW','sLW','sMW','sSW','szmean','nobs');

