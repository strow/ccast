%
% imag_hot2 -- long span hot scene complex residual stats
%
% multi-day mean and std for brightness temp spectra and
% complex residuals with per-FOV temperature band subsetting,
% also incudes ccast mean NEdN; uses checkSDR for validation
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
% tstr = 'sdr60';     % low res
  tstr = 'sdr60_hr';  % high res
syear = fullfile('/asl/data/cris/ccast', tstr, '2016');

% SDR days of the year
% sdays =  18 :  20;   % 18-20 Jan 2016, noaa test days
  sdays =  20;         % lots of bad data, esp for the SW
% sdays =  61 :  63;   % 1-3 Mar 2016, randomly chosen 2016
% sdays =  61;         % for a quick test
% sdays = 245 : 247;   % 1-3 Sep 2016, randomly chosen 2016
% sdays = 1 : 19 : 366;  % longer test

% checkSDR options
opt1 = struct;
opt1.emsg = false;

% loop initialization
% nLW = 717; nMW = 437; nSW = 163; % low res sizes
  nLW = 717; nMW = 869; nSW = 637; % high res sizes

% recursive mean and var initialization
bmLW = zeros(nLW, 9); bwLW = zeros(nLW, 9); bnLW = zeros(1, 9);
bmMW = zeros(nMW, 9); bwMW = zeros(nMW, 9); bnMW = zeros(1, 9);
bmSW = zeros(nSW, 9); bwSW = zeros(nSW, 9); bnSW = zeros(1, 9);

cmLW = zeros(nLW, 9); cwLW = zeros(nLW, 9); cnLW = zeros(1, 9);
cmMW = zeros(nMW, 9); cwMW = zeros(nMW, 9); cnMW = zeros(1, 9);
cmSW = zeros(nSW, 9); cwSW = zeros(nSW, 9); cnSW = zeros(1, 9);

nmLW = zeros(nLW, 9); nwLW = zeros(nLW, 9); nnLW = 0;
nmMW = zeros(nMW, 9); nwMW = zeros(nMW, 9); nnMW = 0;
nmSW = zeros(nSW, 9); nwSW = zeros(nSW, 9); nnSW = 0;

% total error counts
nimgLW = 0; nimgMW = 0; nimgSW = 0;
nnegLW = 0; nnegMW = 0; nnegSW = 0;

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

    [L1b_err, L1b_stat] = ...
      checkSDR(vLW, vMW, vSW, rLW, rMW, rSW, cLW, cMW, cSW, L1a_err, rid, opt1);

    % cumulative error stats
    nimgLW = nimgLW + sum(L1b_stat.imgLW(:));
    nimgMW = nimgMW + sum(L1b_stat.imgMW(:));
    nimgSW = nimgSW + sum(L1b_stat.imgSW(:));

    nnegLW = nnegLW + sum(L1b_stat.negLW(:));
    nnegMW = nnegMW + sum(L1b_stat.negMW(:));
    nnegSW = nnegSW + sum(L1b_stat.negSW(:));

    % loop on scans
    [m, n, k, nscan] = size(rLW);
    for j = 1 : nscan

      % loop on selected FORs
      for i = sFOR

        % loop on FOVs
        for k = 1 : 9

        % skip any bad data
        if L1b_err(k, i, j)
          continue
        end

        % temp vars for this iteration
        ctmpLW = cLW(:, k, i, j);
        ctmpMW = cMW(:, k, i, j);
        ctmpSW = cSW(:, k, i, j);

        btmpLW = real(rad2bt(vLW, rLW(:, k, i, j)));
        btmpMW = real(rad2bt(vMW, rMW(:, k, i, j)));
        btmpSW = real(rad2bt(vSW, rSW(:, k, i, j)));

        Tsw = rms(btmpSW(400:637));
        if ~(290 <= Tsw & Tsw < 300)
          continue
        end

        % recursive mean and variance
        [bmLW(:,k), bwLW(:,k), bnLW(k)] = ...
                     rec_var(bmLW(:,k), bwLW(:,k), bnLW(k), btmpLW);
        [bmMW(:,k), bwMW(:,k), bnMW(k)] = ...
                     rec_var(bmMW(:,k), bwMW(:,k), bnMW(k), btmpMW);
        [bmSW(:,k), bwSW(:,k), bnSW(k)] = ...
                     rec_var(bmSW(:,k), bwSW(:,k), bnSW(k), btmpSW);

        [cmLW(:,k), cwLW(:,k), cnLW(k)] = ...
                     rec_var(cmLW(:,k), cwLW(:,k), cnLW(k), ctmpLW);
        [cmMW(:,k), cwMW(:,k), cnMW(k)] = ...
                     rec_var(cmMW(:,k), cwMW(:,k), cnMW(k), ctmpMW);
        [cmSW(:,k), cwSW(:,k), cnSW(k)] = ...
                     rec_var(cmSW(:,k), cwSW(:,k), cnSW(k), ctmpSW);

        end % loop on k, FOVs
      end % loop on i, FORs
    end % loop on j, scans

    % loop on sweep direction for NEdN means
    for i = 1 : 2
      [nmLW, nwLW, nnLW] = rec_var(nmLW, nwLW, nnLW, nLW(:,:,i));
      [nmMW, nwMW, nnMW] = rec_var(nmMW, nwMW, nnMW, nMW(:,:,i));
      [nmSW, nwSW, nnSW] = rec_var(nmSW, nwSW, nnSW, nSW(:,:,i));
    end

  if mod(fi, 10) == 0, fprintf(1, '.'), end
  end % loop on fi, files
  fprintf(1, '\n')
end % loop on di, days

% get variance and std
bvLW = bwLW ./ (bnLW - 1);  bsLW = sqrt(bvLW);
bvMW = bwMW ./ (bnMW - 1);  bsMW = sqrt(bvMW);
bvSW = bwSW ./ (bnSW - 1);  bsSW = sqrt(bvSW);

cvLW = cwLW ./ (cnLW - 1);  csLW = sqrt(cvLW);
cvMW = cwMW ./ (cnMW - 1);  csMW = sqrt(cvMW);
cvSW = cwSW ./ (cnSW - 1);  csSW = sqrt(cvSW);

% save the data
save('imag_hot290', ...
     'vLW', 'vMW', 'vSW', 'bnLW', 'bnMW', 'bnSW', ...
     'bmLW', 'bmMW', 'bmSW', 'bsLW', 'bsMW', 'bsSW', ...
     'cmLW', 'cmMW', 'cmSW', 'csLW', 'csMW', 'csSW', ...
     'nmLW', 'nmMW', 'nmSW', ...
     'nimgLW', 'nimgMW', 'nimgSW', 'nnegLW', 'nnegMW', 'nnegSW', ...
     'userLW', 'userMW', 'userSW', 'tstr', 'sFOR');

