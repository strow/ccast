%
% cris_tbin -- temperature bins for CrIS ccast obs
%

addpath ../source

% year and path to data
% ayear = '/asl/data/cris/ccast/sdr60_hr/2016';
  ayear = '/asl/data/cris/ccast/sdr60_hr/2017';

% specify days of the year
% dlist = 1 : 71 : 365;
% dlist = 1 : 13 : 365;
  dlist = 21 : 56;

% specify FORs
iFOR = 15:16;
nFOR = length(iFOR);

% freq span for Tb
% v1 =  899; v2 =  904;
  v1 = 2450; v2 = 2550;

% initialize bins
tind = 200 : 2 : 340;
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
%   d1 = load(afile, 'vLW', 'rLW', 'L1b_err');
%   ixv = find(v1 <= d1.vLW & d1.vLW <=v2);
%   arad = d1.rLW(ixv,:,iFOR,:);
%   afrq = d1.vLW(ixv);

    % just load SW radiances
    d1 = load(afile, 'vSW', 'rSW', 'L1b_err');
    ixv = find(v1 <= d1.vSW & d1.vSW <=v2);
    arad = d1.rSW(ixv,:,iFOR,:);
    afrq = d1.vSW(ixv);

%  % new L1b_err local calc
%   L1b_err = ...
%      checkSDR(d1.vLW, d1.vMW, d1.vSW, d1.rLW, d1.rMW, d1.rSW, ...
%               d1.cLW, d1.cMW, d1.cSW, d1.L1a_err, d1.rid);
%   iOK = ~L1b_err(:,iFOR,:);
%   arad = arad(:,iOK);
%
    % new L1b_err from file
    iOK = ~d1.L1b_err(:,iFOR,:);
    arad = arad(:,iOK);

%   % old L1b_err from file
%   iOK = ~d1.L1b_err(iFOR,:);
%   arad = arad(:,:,iOK);
    
    Tb = real(rad2bt(afrq, arad));
    rmsTb = squeeze(rms(Tb));
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

clear d1
save cris_tbin

