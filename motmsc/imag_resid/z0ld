%
% imag_stats2 -- long span CrIS complex residual stats
%
% derived from mean_cfovs, imag_stats1, and mk_climits
% uses data from imag_stats1 or 2 as part of valid data check
%

addpath ../source
addpath ../motmsc/utils
addpath /asl/packages/airs_decon/source

%-----------------
% test parameters
%-----------------
% sFOR = 15;     % offset nadir FOR
% sFOR = 15:16;  % near-nadir FOR pair
  sFOR =  1:30;  % all fields of regard
% aflag = 0;     % set to 1 for ascending

% path to SDR year
  tstr = 'sdr60_hr';
% tstr = 'sdr60';
syear = fullfile('/asl/data/cris/ccast', tstr, '2016');

% SDR days of the year
% sdays =  18 :  20;   % 18-20 Jan 2016, noaa test days
% sdays =  20;         % lots of bad data, esp for the SW
% sdays =  61 :  63;   % 1-3 Mar 2016, randomly chosen 2016
% sdays = 245 : 247;   % 1-3 Sep 2016, randomly chosen 2016
  sdays = 1 : 19 : 366;  % longer test

% residual limits
d1 = load('imag_stats_t10');
kLW = 10; kMW = 10; kSW = 12;
ubLW = d1.cmLW + kLW * d1.csLW;
lbLW = d1.cmLW - kLW * d1.csLW;
ubMW = d1.cmMW + kMW * d1.csMW;
lbMW = d1.cmMW - kMW * d1.csMW;
ubSW = d1.cmSW + kSW * d1.csSW;
lbSW = d1.cmSW - kSW * d1.csSW;
clear d1

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
%       if L1b_err(i, j)
          continue
        end

        % NaN radiance check (not needed with L1b_err)
        if ~isempty(find(isnan(rLW(:, :, i, j)))) || ...
           ~isempty(find(isnan(rMW(:, :, i, j)))) || ...
           ~isempty(find(isnan(rSW(:, :, i, j))))
          continue
        end

        % temp vars for this iteration
        ctmpLW = cLW(:, :, i, j);
        ctmpMW = cMW(:, :, i, j);
        ctmpSW = cSW(:, :, i, j);

        btmpLW = real(rad2bt(vLW, rLW(:, :, i, j)));
        btmpMW = real(rad2bt(vMW, rMW(:, :, i, j)));
        btmpSW = real(rad2bt(vSW, rSW(:, :, i, j)));

        % complex residual range checks
        errLW = ~isempty(find(ctmpLW < lbLW | ubLW < ctmpLW));
        errMW = ~isempty(find(ctmpMW < lbMW | ubMW < ctmpMW));
        errSW = ~isempty(find(ctmpSW < lbSW | ubSW < ctmpSW));

        % take a look at out of range data
        if errLW && 0
          imag_plots2(vLW, btmpLW, ctmpLW, lbLW, ubLW, 'LW', di, fi, i, j);
        end
        if errMW && 0
          imag_plots2(vMW, btmpMW, ctmpMW, lbMW, ubMW, 'MW', di, fi, i, j);
        end
        if errSW && 0
          imag_plots2(vSW, btmpSW, ctmpSW, lbSW, ubSW, 'SW', di, fi, i, j);
        end

        % skip out of range data
        if errLW || errMW || errSW
          continue
        end

        % recursive mean and variance
        [bmLW, bwLW, bnLW] = rec_var(bmLW, bwLW, bnLW, btmpLW);
        [bmMW, bwMW, bnMW] = rec_var(bmMW, bwMW, bnMW, btmpMW);
        [bmSW, bwSW, bnSW] = rec_var(bmSW, bwSW, bnSW, btmpSW);

        [cmLW, cwLW, cnLW] = rec_var(cmLW, cwLW, cnLW, ctmpLW);
        [cmMW, cwMW, cnMW] = rec_var(cmMW, cwMW, cnMW, ctmpMW);
        [cmSW, cwSW, cnSW] = rec_var(cmSW, cwSW, cnSW, ctmpSW);
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
save('imag_stats2', ...
     'vLW', 'vMW', 'vSW', 'bnLW', 'bnMW', 'bnSW', ...
     'bmLW', 'bmMW', 'bmSW', 'bsLW', 'bsMW', 'bsSW', ...
     'cmLW', 'cmMW', 'cmSW', 'csLW', 'csMW', 'csSW', ...
     'userLW', 'userMW', 'userSW', 'tstr', 'sFOR');

