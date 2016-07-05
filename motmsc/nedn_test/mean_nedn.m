%
% mean_nedn - get ccast NEdN average over several days
%

addpath ../source
addpath ../motmsc/utils

%-----------------
% test parameters
%-----------------

% path to SDR year
% tstr = 'e5_Pn_ag';
  tstr = 'nedn_hr3-2';
syear = fullfile('/asl/data/cris/ccast', tstr, '2015');

% SDR days of the year
% sdays =  48 :  50;   % 17-19 Feb 2015
  sdays =  312 : 314;  %

% loop initialization
mLW = 717; mMW = 869; mSW = 637;
nmLW = zeros(mLW, 9, 2); nwLW = zeros(mLW, 9, 2); nnLW = 0;
nmMW = zeros(mMW, 9, 2); nwMW = zeros(mMW, 9, 2); nnMW = 0;
nmSW = zeros(mSW, 9, 2); nwSW = zeros(mSW, 9, 2); nnSW = 0;

% loop on days and files
for di = sdays

  % loop on SDR files
  doy = sprintf('%03d', di);
  flist = dir(fullfile(syear, doy, 'SDR*.mat'));
  for fi = 1 : length(flist);

    % load the SDR data
    rid = flist(fi).name(5:22);
    stmp = ['SDR_', rid, '.mat'];
    sfile = fullfile(syear, doy, stmp);
    load(sfile)

    % recursive mean and variance
    [nmLW, nwLW, nnLW] = rec_var(nmLW, nwLW, nnLW, nLW);
    [nmMW, nwMW, nnMW] = rec_var(nmMW, nwMW, nnMW, nMW);
    [nmSW, nwSW, nnSW] = rec_var(nmSW, nwSW, nnSW, nSW);

    if mod(fi, 10) == 0, fprintf(1, '.'), end
  end
  fprintf(1, '\n')
end

% get variance and std
nvLW = nwLW ./ (nnLW - 1);  nsLW = sqrt(nvLW);
nvMW = nwMW ./ (nnMW - 1);  nsMW = sqrt(nvMW);
nvSW = nwSW ./ (nnSW - 1);  nsSW = sqrt(nvSW);

% save the data
save(sprintf('nedn_%s', tstr), ...
     'vLW', 'vMW', 'vSW', 'nnLW', 'nnMW', 'nnSW', ...
     'nmLW', 'nmMW', 'nmSW', 'nsLW', 'nsMW', 'nsSW', ...
     'userLW', 'userMW', 'userSW', 'tstr');

