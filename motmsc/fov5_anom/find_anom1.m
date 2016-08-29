%
% find_anom -- look for representative FOV 5 cold scene anomaly
%

addpath ../source
addpath ../motmsc/utils

%-----------------
% test parameters
%-----------------
sFOR = 15:16;  % fields of regard, 1-30

% path to SDR year
tstr = 'sdr60';
syear = fullfile('/asl/data/cris/ccast', tstr, '2016');

% SDR days of the year
% sdays =  1 : 3;
  sdays =  3;

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

    % loop on scans
    [m, n, k, nscan] = size(rLW);
    for j = 1 : nscan

      % loop on selected FORs
      for i = sFOR
        if L1a_err(i, j)
          continue
        end
        if ~isempty(find(isnan(rLW(:, :, i, j))))
          continue
        end

        bLW = real(rad2bt(vLW, rLW(:, :, i, j)));
        t668 = mean(bLW(32, :));
        t900 = mean(bLW(403, :));
        tdif = fovdiff(bLW);
    
%       if tdif < 1 && t900 < 230
%          fprintf(1, 'cold window, rid = %s, ', rid)
%          fprintf(1, 't668 = %d, scan = %2d, FOR = %2d\n', round(t668), j, i)
%       end

        if tdif < 1 && t900 > 270
           fprintf(1, 'warm window, rid = %s, ', rid)
           fprintf(1, 't668 = %d, scan = %2d, FOR = %2d\n', round(t668), j, i)
        end

      end
    end
  end
end

