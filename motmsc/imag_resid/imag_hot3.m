%
% imag_hot3 -- SW temp x complex residuals
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

btab = ones(9, 30, 60, 180) * NaN;
ctab = ones(9, 30, 60, 180) * NaN;

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
%       ctmpLW = cLW(:, k, i, j);
%       ctmpMW = cMW(:, k, i, j);
        ctmpSW = cSW(:, k, i, j);

%       btmpLW = real(rad2bt(vLW, rLW(:, k, i, j)));
%       btmpMW = real(rad2bt(vMW, rMW(:, k, i, j)));
        btmpSW = real(rad2bt(vSW, rSW(:, k, i, j)));

        btab(k, i, j, fi) = rms(btmpSW(400:637));
        ctab(k, i, j, fi) = rms(ctmpSW(400:637));

        end % loop on k, FOVs
      end % loop on i, FORs
    end % loop on j, scans

  if mod(fi, 10) == 0, fprintf(1, '.'), end
  end % loop on fi, files
  fprintf(1, '\n')
end % loop on di, days

% save the data
save imag_hot3 btab ctab

% quick look
figure(1); clf
j = 5;
subplot(2,1,1)
plot(squeeze(btab(j,:)), squeeze(ctab(j,:)), '.')
axis([200, 340, 0, 0.03])
title(sprintf('FOV %d complex residual vs Tb', j))
ylabel('radiance')
grid on

j = 3;
subplot(2,1,2)
plot(squeeze(btab(j,:)), squeeze(ctab(j,:)), '.')
axis([200, 340, 0, 0.03])
title(sprintf('FOV %d complex residual vs Tb', j))
xlabel('Tb, K')
ylabel('radiance')
grid on

