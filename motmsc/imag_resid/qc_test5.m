%
% qc_test5 - browse errors flagged by checkSDR
%

addpath utils
addpath ../source
addpath ../motmsc/utils
addpath /asl/packages/airs_decon/source

%-----------------
% test parameters
%-----------------
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

% total error counts
nimgLW = 0; nimgMW = 0; nimgSW = 0;
nnegLW = 0; nnegMW = 0; nnegSW = 0;
nnanLW = 0; nnanMW = 0; nnanSW = 0;

% plot names and colors
fname = fovnames;
fcolor = fovcolors;

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
      checkSDRv1(vLW, vMW, vSW, rLW, rMW, rSW, cLW, cMW, cSW, ...
                 L1a_err, rid, opt1);

    % cumulative error stats
    nimgLW = nimgLW + sum(L1b_stat.imgLW(:));
    nimgMW = nimgMW + sum(L1b_stat.imgMW(:));
    nimgSW = nimgSW + sum(L1b_stat.imgSW(:));

    nnegLW = nnegLW + sum(L1b_stat.negLW(:));
    nnegMW = nnegMW + sum(L1b_stat.negMW(:));
    nnegSW = nnegSW + sum(L1b_stat.negSW(:));

    % loop on scans
    ej = 0;
    [m, n, k, nscan] = size(rLW);
    for j = 1 : nscan

      % loop on selected FORs
      ei = 0;
      for i = sFOR

        % continue if L1a error or no L1b error
        if L1a_err(i, j) || ~cOR(L1b_err(:, i, j))
          continue
        end

        ei = ei + 1;
        ej = ej + 1;
        if ei > 3, break, end

        % temp vars for this iteration
        ctmpLW = cLW(:, :, i, j);
        ctmpMW = cMW(:, :, i, j);
        ctmpSW = cSW(:, :, i, j);

        btmpLW = real(rad2bt(vLW, rLW(:, :, i, j)));
        btmpMW = real(rad2bt(vMW, rMW(:, :, i, j)));
        btmpSW = real(rad2bt(vSW, rSW(:, :, i, j)));

        % status message
        fprintf(1, '%s day %d file %d scan %d FOR %d\n', rid, di, fi, j, i);

        simgLW = sum(L1b_stat.imgLW(:,i,j));
        simgMW = sum(L1b_stat.imgMW(:,i,j));
        simgSW = sum(L1b_stat.imgSW(:,i,j));

        snegLW = sum(L1b_stat.negLW(:,i,j));
        snegMW = sum(L1b_stat.negMW(:,i,j));
        snegSW = sum(L1b_stat.negSW(:,i,j));

        shotLW = sum(L1b_stat.hotLW(:,i,j));
        shotMW = sum(L1b_stat.hotMW(:,i,j));
        shotSW = sum(L1b_stat.hotSW(:,i,j));

        if simgLW > 0, fprintf('LW imag resid %d\n', simgLW), end
        if simgMW > 0, fprintf('MW imag resid %d\n', simgMW), end
        if simgSW > 0, fprintf('SW imag resid %d\n', simgSW), end

        if snegLW > 0, fprintf('LW neg rad %d\n', snegLW), end
        if snegMW > 0, fprintf('MW neg rad %d\n', snegMW), end
        if snegSW > 0, fprintf('SW neg rad %d\n', snegSW), end

        if shotLW > 0, fprintf('LW hot scene %d\n', shotLW), end
        if shotMW > 0, fprintf('MW hot scene %d\n', shotMW), end
        if shotSW > 0, fprintf('SW hot scene %d\n', shotSW), end

        % SW figure
        itmp = ...
          L1b_stat.imgSW(:,i,j) | L1b_stat.negSW(:,i,j) | L1b_stat.hotSW(:,i,j);
        ifov = find(itmp > 0);
        if ~isempty(ifov)

          figure(1); clf
          set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
          set(gcf, 'DefaultAxesColorOrder', fovcolors);
          subplot(2,1,1)
          plot(vSW, btmpSW)
          ax = axis; ax(1) = 2150; ax(2) = 2550; axis(ax)
          title('SW spectra')
          legend(fname, 'location', 'southwest')
          ylabel('Tb, K')
          grid on; zoom on

          subplot(2,1,2)
          set(gcf, 'DefaultAxesColorOrder', fcolor(ifov, :));
          plot(vSW, ctmpSW(:,ifov), ...
               vSW, L1b_stat.cUBSW(:,ifov), 'k', ...
               vSW, L1b_stat.cLBSW(:,ifov), 'k')

          title('SW complex residuals')
          ax = axis; ax(1) = 2150; ax(2) = 2550; axis(ax)
          legend(fname{ifov}, 'upper bound', 'lower bound', ...
                 'location', 'southwest')
          ylabel('radiance')
          xlabel('wavenumber')
          grid on; zoom on

          if length(ifov) > 1
              ftmp = sprintf('SW_%s_%d_%d_%d_%d', rid, di, fi, j, i);
              saveas(gcf, ftmp, 'png')
          end

%         switch input('continue > ', 's');
%           case 's'
%             ftmp = sprintf('SW_%s_%d_%d_%d_%d', rid, di, fi, j, i);
%             saveas(gcf, ftmp, 'png')
%           case 'k'
%             keyboard
%         end
        end % SW figure

        % MW figure
        itmp = ...
          L1b_stat.imgMW(:,i,j) | L1b_stat.negMW(:,i,j) | L1b_stat.hotMW(:,i,j);
        ifov = find(itmp > 0);
        if ~isempty(ifov)

          figure(1); clf
          % set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
          set(gcf, 'DefaultAxesColorOrder', fovcolors);
          subplot(2,1,1)
          plot(vMW, btmpMW)
          ax = axis; ax(1) = 1200; ax(2) = 1750; axis(ax)
          title('MW spectra')
          legend(fname, 'location', 'southwest')
          ylabel('Tb, K')
          grid on; zoom on

          subplot(2,1,2)
          set(gcf, 'DefaultAxesColorOrder', fcolor(ifov, :));
          plot(vMW, ctmpMW(:,ifov), ...
               vMW, L1b_stat.cUBMW(:,ifov), 'k', ...
               vMW, L1b_stat.cLBMW(:,ifov), 'k')

          title('MW complex residuals')
          ax = axis; ax(1) = 1200; ax(2) = 1750; axis(ax)
          legend(fname{ifov}, 'upper bound', 'lower bound', ...
                 'location', 'southwest')
          ylabel('radiance')
          xlabel('wavenumber')
          grid on; zoom on

          ftmp = sprintf('MW_%s_%d_%d_%d_%d', rid, di, fi, j, i);
          saveas(gcf, ftmp, 'png')

%         switch input('continue > ', 's');
%           case 's'
%             ftmp = sprintf('MW_%s_%d_%d_%d_%d', rid, di, fi, j, i);
%             saveas(gcf, ftmp, 'png')
%           case 'k'
%             keyboard
%         end
        end % MW figure

        % LW figure
        itmp = ...
          L1b_stat.imgLW(:,i,j) | L1b_stat.negLW(:,i,j) | L1b_stat.hotLW(:,i,j);
        ifov = find(itmp > 0);
        if ~isempty(ifov)

          figure(1); clf
          % set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
          set(gcf, 'DefaultAxesColorOrder', fovcolors);
          subplot(2,1,1)
          plot(vLW, btmpLW)
          ax = axis; ax(1) = 650; ax(2) = 1100; axis(ax)
          title('LW spectra')
          legend(fname, 'location', 'south')
          ylabel('Tb, K')
          grid on; zoom on

          subplot(2,1,2)
          set(gcf, 'DefaultAxesColorOrder', fcolor(ifov, :));
          plot(vLW, ctmpLW(:,ifov), ...
               vLW, L1b_stat.cUBLW(:,ifov), 'k', ...
               vLW, L1b_stat.cLBLW(:,ifov), 'k')

          title('LW complex residuals')
          axis([650, 1100, -1.5, 1.5])
          ax = axis; ax(1) = 650; ax(2) = 1100; axis(ax)
          legend(fname{ifov}, 'upper bound', 'lower bound', ...
                 'location', 'north')
          ylabel('radiance')
          xlabel('wavenumber')
          grid on; zoom on

          ftmp = sprintf('LW_%s_%d_%d_%d_%d', rid, di, fi, j, i);
          saveas(gcf, ftmp, 'png')

%         switch input('continue > ', 's');
%           case 's'
%             ftmp = sprintf('LW_%s_%d_%d_%d_%d', rid, di, fi, j, i);
%             saveas(gcf, ftmp, 'png')
%           case 'k'
%             keyboard
%         end
        end % LW figure

      end % loop on i, FORs
      if ej > 9, break, end
    end % loop on j, scans

  end % loop on fi, files
end % loop on di, days

