%
% mean_cfovs - mean and std for each FOV over selected FORs
%
% loop on days and granules and take the mean and standard deviation
% for each FOV for a subset of FORs
%

addpath ../source
addpath ../motmsc/utils

%-----------------
% test parameters
%-----------------
% sFOR = 15;     % fields of regard, 1-30
  sFOR = 15:16;  % fields of regard, 1-30
aflag = 0;       % set to 1 for ascending

% path to SDR year
tstr = 'e5_Pn_ag';
syear = fullfile('/asl/data/cris/ccast', tstr, '2015');

% SDR days of the year
sdays =  48 :  50;  % 17-19 Feb 2015

% loop initialization
nLW = 717; nMW = 869; nSW = 637; % high res sizes
bmLW = zeros(nLW, 9); bwLW = zeros(nLW, 9); bnLW = 0;
bmMW = zeros(nMW, 9); bwMW = zeros(nMW, 9); bnMW = 0;
bmSW = zeros(nSW, 9); bwSW = zeros(nSW, 9); bnSW = 0;

%------------------------
% loop on days and files
%------------------------
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

    % get ascending flag for current scans
    atmp = lat2aflag(squeeze(geo.Latitude(5, sFOR(1), :)));

    % loop on scans
    [m, n, k, nscan] = size(rLW);
    for j = 1 : nscan
      if isnan(atmp(j)) || atmp(j) ~= aflag
        continue
      end
      % loop on selected FORs
      for i = sFOR
        if L1a_err(i, j)
          continue
        end
        bLW = real(rad2bt(vLW, rLW(:, :, i, j)));
        bMW = real(rad2bt(vMW, rMW(:, :, i, j)));
        bSW = real(rad2bt(vSW, rSW(:, :, i, j)));
        if ~isempty(find(isnan(bLW)))
          continue
        end
        [bmLW, bwLW, bnLW] = rec_var(bmLW, bwLW, bnLW, bLW);
        [bmMW, bwMW, bnMW] = rec_var(bmMW, bwMW, bnMW, bMW);
        [bmSW, bwSW, bnSW] = rec_var(bmSW, bwSW, bnSW, bSW);
      end
    end
    if mod(fi, 10) == 0, fprintf(1, '.'), end
  end
  fprintf(1, '\n')
end

% get variance and std
bvLW = bwLW ./ (bnLW - 1);  bsLW = sqrt(bvLW);
bvMW = bwMW ./ (bnMW - 1);  bsMW = sqrt(bvMW);
bvSW = bwSW ./ (bnSW - 1);  bsSW = sqrt(bvSW);

% save the data
save(sprintf('ccast_%s_%s', tstr, seq2str(sFOR)), ...
     'vLW', 'vMW', 'vSW', 'bmLW', 'bmMW', 'bmSW', ...
     'bsLW', 'bsMW', 'bsSW', 'bnLW', 'bnMW', 'bnSW', ...
     'userLW', 'userMW', 'userSW', 'tstr', 'sFOR');

