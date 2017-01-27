%
% rad_stats1 -- long span CrIS radiance stats
%
% derived from mean_cfovs; version for complex residuals
%

addpath ../source
addpath ../motmsc/utils
addpath /asl/packages/airs_decon/source

%-----------------
% test parameters
%-----------------
% sFOR = 15;     % fields of regard, 1-30
  sFOR = 15:16;  % fields of regard, 1-30
% aflag = 0;     % set to 1 for ascending

% path to SDR year
  tstr = 'sdr60_hr';
% tstr = 'sdr60';
syear = fullfile('/asl/data/cris/ccast', tstr, '2016');

% SDR days of the year
% sdays =  48 :  50;   % 17-19 Feb 2015
  sdays =  18 :  20;   % 2016 noaa test days
% sdays =  61 :  63;   % randomly chosen 2016

% loop initialization
nLW = 717; nMW = 869; nSW = 637; % high res sizes
bmLW = zeros(nLW, 9); bwLW = zeros(nLW, 9); bnLW = 0;
bmMW = zeros(nMW, 9); bwMW = zeros(nMW, 9); bnMW = 0;
bmSW = zeros(nSW, 9); bwSW = zeros(nSW, 9); bnSW = 0;

cmLW = zeros(nLW, 9); cwLW = zeros(nLW, 9); cnLW = 0;
cmMW = zeros(nMW, 9); cwMW = zeros(nMW, 9); cnMW = 0;
cmSW = zeros(nSW, 9); cwSW = zeros(nSW, 9); cnSW = 0;

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
%     if isnan(atmp(j)) || atmp(j) ~= aflag
%       continue
%     end
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

        tmpLW = double(cLW(:, :, i, j));
        tmpMW = double(cMW(:, :, i, j));
        tmpSW = double(cSW(:, :, i, j));

        t1 = rms(tmpSW);
        t2 = find(t1 > 0.10);
        if ~isempty(t2)
          [i, j, t2], rid
          continue
        end

        [bmLW, bwLW, bnLW] = rec_var(bmLW, bwLW, bnLW, bLW);
        [bmMW, bwMW, bnMW] = rec_var(bmMW, bwMW, bnMW, bMW);
        [bmSW, bwSW, bnSW] = rec_var(bmSW, bwSW, bnSW, bSW);

        [cmLW, cwLW, cnLW] = rec_var(cmLW, cwLW, cnLW, tmpLW);
        [cmMW, cwMW, cnMW] = rec_var(cmMW, cwMW, cnMW, tmpMW);
        [cmSW, cwSW, cnSW] = rec_var(cmSW, cwSW, cnSW, tmpSW);
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

cvLW = cwLW ./ (cnLW - 1);  csLW = sqrt(cvLW);
cvMW = cwMW ./ (cnMW - 1);  csMW = sqrt(cvMW);
cvSW = cwSW ./ (cnSW - 1);  csSW = sqrt(cvSW);

% save the data
save('rad_stats1', ...
     'vLW', 'vMW', 'vSW', 'bnLW', 'bnMW', 'bnSW', ...
     'bmLW', 'bmMW', 'bmSW', 'bsLW', 'bsMW', 'bsSW', ...
     'cmLW', 'cmMW', 'cmSW', 'csLW', 'csMW', 'csSW', ...
     'userLW', 'userMW', 'userSW', 'tstr', 'sFOR');

