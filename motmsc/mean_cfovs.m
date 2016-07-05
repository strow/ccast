%
% mean_cfovs - mean and std for each ccast FOV over selected FORs
%
% loop on days and ccast SDR files and take the mean and standard
% deviation for each FOV for a subset of FORs
%

addpath ../source
addpath ../motmsc/utils
addpath /asl/packages/airs_decon/source

%-----------------
% test parameters
%-----------------
  sFOR = 16;     % fields of regard, 1-30
% sFOR = 15:16;  % fields of regard, 1-30
aflag = 0;       % set to 1 for ascending

% path to SDR year
% tstr = 'sdr60_hr';
  tstr = 'e7r4hr3';
syear = fullfile('/asl/data/cris/ccast', tstr, '2016');

% SDR days of the year
% sdays =  48 :  50;   % 17-19 Feb 2015
% sdays =  338 : 340;  % recent non-lin test
  sdays =  18 : 20;    % new NOAA test

% loop initialization
nLW = 717; nMW = 869; nSW = 637; % high res sizes
bmLW = zeros(nLW, 9); bwLW = zeros(nLW, 9); bnLW = 0;
bmMW = zeros(nMW, 9); bwMW = zeros(nMW, 9); bnMW = 0;
bmSW = zeros(nSW, 9); bwSW = zeros(nSW, 9); bnSW = 0;

amLW = zeros(nLW, 9); awLW = zeros(nLW, 9); anLW = 0;
amMW = zeros(nMW, 9); awMW = zeros(nMW, 9); anMW = 0;
amSW = zeros(nSW, 9); awSW = zeros(nSW, 9); anSW = 0;

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
        if ~isempty(find(isnan(rLW(:, :, i, j))))
          continue
        end
        bLW = real(rad2bt(vLW, rLW(:, :, i, j)));
        bMW = real(rad2bt(vMW, rMW(:, :, i, j)));
        bSW = real(rad2bt(vSW, rSW(:, :, i, j)));

        aLW = real(rad2bt(vLW, hamm_app(double(rLW(:, :, i, j)))));
        aMW = real(rad2bt(vMW, hamm_app(double(rMW(:, :, i, j)))));
        aSW = real(rad2bt(vSW, hamm_app(double(rSW(:, :, i, j)))));

        [bmLW, bwLW, bnLW] = rec_var(bmLW, bwLW, bnLW, bLW);
        [bmMW, bwMW, bnMW] = rec_var(bmMW, bwMW, bnMW, bMW);
        [bmSW, bwSW, bnSW] = rec_var(bmSW, bwSW, bnSW, bSW);

        [amLW, awLW, anLW] = rec_var(amLW, awLW, anLW, aLW);
        [amMW, awMW, anMW] = rec_var(amMW, awMW, anMW, aMW);
        [amSW, awSW, anSW] = rec_var(amSW, awSW, anSW, aSW);
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

avLW = awLW ./ (anLW - 1);  asLW = sqrt(avLW);
avMW = awMW ./ (anMW - 1);  asMW = sqrt(avMW);
avSW = awSW ./ (anSW - 1);  asSW = sqrt(avSW);

% save the data
save(sprintf('ccast_%s_%s', tstr, seq2str(sFOR)), ...
     'vLW', 'vMW', 'vSW', 'bnLW', 'bnMW', 'bnSW', ...
     'bmLW', 'bmMW', 'bmSW', 'bsLW', 'bsMW', 'bsSW', ...
     'amLW', 'amMW', 'amSW', 'asLW', 'asMW', 'asSW', ...
     'userLW', 'userMW', 'userSW', 'tstr', 'sFOR');

