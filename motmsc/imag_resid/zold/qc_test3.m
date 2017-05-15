%
% qc_test3 - check complex residuals vs L1b_err
%

addpath ../source
addpath ../motmsc/utils
addpath /asl/packages/airs_decon/source

% complex residual upper bounds
cUBLW = 1.5;
cUBMW = 0.5;
cUBSW = 0.05;

% max messages per granule
emax = 4;

% path to SDR year
% tstr = 'sdr60_hr';
  tstr = 'h3noaa4';
% tstr = 'sdr60';
syear = fullfile('/asl/data/cris/ccast', tstr, '2016');

% SDR days of the year
% sdays =  48 : 50;   % 17-19 Feb 2015
  sdays =  18 : 20;   % 2016 noaa test days (many SW errors...)
% sdays =  61 : 63;   % randomly chosen 2016
% sdays =  91 : 93;
% sdays = 101 : 102;
% sdays =  33 : 36;

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

    % current status flag
    L1b_err = checkSDR(vLW, vMW, vSW, rLW, rMW, rSW, L1a_err, rid);

    % check complex residuals
    [n1, n2, n3, nscan] = size(rSW);
    ecnt = 0;

    % loop on scans and FORs
    for j = 1 : nscan
      for i = 1 : 30

        % no check if we have an L1a error
        if L1a_err(i, j)
          continue
        end

        % LW checks
        ctmp = cLW(:, :, i, j);
        if ~isempty(find(ctmp > cUBLW, 1))
          fprintf(1, 'scan %d FOR %d, cLW > limit, L1b_err %d\n', ...
                  j, i, L1b_err(i, j))
          bLW = real(rad2bt(vLW, rLW(:, :, i, j)));
          figure(1); clf
          set(gcf, 'DefaultAxesColorOrder', fovcolors);
          subplot(2,1,1)
          plot(vLW, bLW)
          ax = axis; ax(1) = 650; ax(2) = 1100; axis(ax)
          title('associated spectra')
          legend(fovnames, 'location', 'eastoutside')
          ylabel('Tb, K')
          grid on; zoom on

          subplot(2,1,2)
          plot(vLW, ctmp)
          ax = axis; ax(1) = 650; ax(2) = 1100; axis(ax)
          title('complex residuals')
          legend(fovnames, 'location', 'eastoutside')
          ylabel('radiance')
          xlabel('wavenumber')
          grid on; zoom on

          input('ret to continue > ');
        end

        % MW checks
        ctmp = cMW(:, :, i, j);
        if ~isempty(find(ctmp > cUBMW, 1))
          fprintf(1, 'scan %d FOR %d, cMW > limit, L1b_err %d\n', ...
                  j, i, L1b_err(i, j))
        end

        % SW checks
        ctmp = cSW(:, :, i, j);
        if ~isempty(find(ctmp > cUBSW, 1))
          fprintf(1, 'scan %d FOR %d, cSW > limit, L1b_err %d\n', ...
                  j, i, L1b_err(i, j))
%         b1 = real(rad2bt(vSW, rSW(:, :, i, j)));
%         figure(1); clf
%         set(gcf, 'DefaultAxesColorOrder', fovcolors);
%         subplot(2,1,1)
%         plot(vSW, b1)
%         ax = axis; ax(1) = 2150; ax(2) = 2550; axis(ax)
%         title('associated spectra')
%         legend(fovnames, 'location', 'eastoutside')
%         ylabel('Tb, K')
%         grid on; zoom on
% 
%         subplot(2,1,2)
%         plot(vSW, ctmp)
%         ax = axis; ax(1) = 2150; ax(2) = 2550; axis(ax)
%         title('complex residuals')
%         legend(fovnames, 'location', 'eastoutside')
%         ylabel('radiance')
%         xlabel('wavenumber')
%         grid on; zoom on
% 
%         input('ret to continue > ');
        end

      end
    end
  end
end

