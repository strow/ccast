%
% NAME
%   checkSDR -- basic SDR validation
%
% SYNOPSIS
%   L1b_err = checkSDR(vLW, vMW, vSW, rLW, rMW, rSW, L1a_err, rid);
%
% INPUTS
%   vLW     - nchan LW frequency
%   vMW     - nchan MW frequency
%   vSW     - nchan SW frequency
%   rLW     - nchan x 9 x 30 x nscan LW radiance
%   rMW     - nchan x 9 x 30 x nscan MW radiance
%   rSW     - nchan x 9 x 30 x nscan SW radiance
%   L1a_err - 30 x nchan L1a error flags
%   rid     - RDR time and date string, for messages
%
% OUTPUTS
%   L1b_err - 30 x nchan L1b error flags
%
% DISCUSSION
%   basic range and NaN checks for all three bands
%
% AUTHOR
%   H. Motteler, 26 Jan 2017
%

function L1b_err = checkSDR(vLW, vMW, vSW, rLW, rMW, rSW, L1a_err, rid)

% max messages printed
emax = 4;

% radiance upper bounds
rUBLW = bt2rad(vLW, 350) * ones(1, 9);
rUBMW = bt2rad(vMW, 350) * ones(1, 9);
rUBSW = bt2rad(vSW, 360) * ones(1, 9);

% radiance lower bounds
rLBLW = 0;
rLBMW = -1.0;
rLBSW = -0.1;

% initialize output
[n1, n2, n3, nscan] = size(rSW);
L1b_err = zeros(30, nscan);
ecnt = 0;

% loop on scans and FORs
for j = 1 : nscan
  for i = 1 : 30

    % no check if we have an L1a error
    if L1a_err(i, j)
      L1b_err(i, j) = 1;
      continue
    end

    % LW checks
    rtmp = rLW(:, :, i, j);
    if ~isempty(find(rtmp < rLBLW, 1))
      L1b_err(i, j) = 1;
      ecnt = ecnt + 1;
      if ecnt <= emax
        err_msg(i, j, rid, 'LW neg rad')
%       err_plot(i, j, rid, vLW, rtmp, 'rad')
      end
      continue
    end
    if ~isempty(find(rUBLW < rtmp, 1))
      L1b_err(i, j) = 1;
      ecnt = ecnt + 1;
      if ecnt <= emax
        err_msg(i, j, rid, 'LW too hot')
%       err_plot(i, j, rid, vLW, rtmp, 'bt')
      end
      continue
    end
    if ~isempty(find(isnan(rtmp), 1))
      L1b_err(i, j) = 1;
      ecnt = ecnt + 1;
      if ecnt <= emax
        err_msg(i, j, rid, 'LW L1b NaN')
      end
      continue
    end

    % MW checks
    rtmp = rMW(:, :, i, j);
    if ~isempty(find(rtmp < rLBMW, 1))
      L1b_err(i, j) = 1;
      ecnt = ecnt + 1;
      if ecnt <= emax
        err_msg(i, j, rid, 'MW neg rad')
%       err_plot(i, j, rid, vMW, rtmp, 'rad')
      end
      continue
    end
    if ~isempty(find(rUBMW < rtmp, 1))
      L1b_err(i, j) = 1;
      ecnt = ecnt + 1;
      if ecnt <= emax
        err_msg(i, j, rid, 'MW too hot')
%       err_plot(i, j, rid, vMW, rtmp, 'bt')
      end
      continue
    end
    if ~isempty(find(isnan(rtmp), 1))
      L1b_err(i, j) = 1;
      ecnt = ecnt + 1;
      if ecnt <= emax
        err_msg(i, j, rid, 'MW L1b NaN')
      end
      continue
    end

    % SW checks
    rtmp = rSW(:, :, i, j);
    if ~isempty(find(rtmp < rLBSW, 1))
      L1b_err(i, j) = 1;
      ecnt = ecnt + 1;
      if ecnt <= emax
        err_msg(i, j, rid, 'SW neg rad')
%       err_plot(i, j, rid, vSW, rtmp, 'rad')
      end
      continue
    end
    if ~isempty(find(rUBSW < rtmp, 1))
      L1b_err(i, j) = 1;
      ecnt = ecnt + 1;
      if ecnt <= emax
        err_msg(i, j, rid, 'SW too hot')
%       err_plot(i, j, rid, vSW, rtmp, 'bt')
      end
      continue
    end
    if ~isempty(find(isnan(rtmp), 1))
      L1b_err(i, j) = 1;
      ecnt = ecnt + 1;
      if ecnt <= emax
        err_msg(i, j, rid, 'SW L1b NaN')
      end
      continue
    end

  end
end

% total bad FORs
nerr = sum(L1b_err(:));
if nerr > 0
  fprintf(1, 'checkSDR: %s %d SDR errors\n', rid, nerr)
end
end % checkSDR

% print error messages
function err_msg(i, j, rid, msg)
   fprintf(1, 'checkSDR: scan %d FOR %d, %s \n', j, i, msg)
end % err_msg

% plot error spectra
function err_plot(i, j, rid, vx, rx, pt)
  fprintf(1, 'min rad %g, max rad %g\n', min(rx(:)), max(rx(:)))
  fnames = fovnames;
  fcolor = fovcolors;
  rid = strrep(rid, '_', ' ');
  figure(1); clf
  set(gcf, 'DefaultAxesColorOrder', fcolor);
  switch(pt)

    case 'bt',
    plot(vx, real(rad2bt(vx, rx)))
    title(sprintf('%s scan %d FOR %d', rid, j, i))
    legend(fovnames, 'location', 'best')
    xlabel('wavenumber')
    ylabel('Tb, K')
    grid on; zoom on

    case 'rad',   
    plot(vx, rx)
    title(sprintf('%s scan %d FOR %d', rid, j, i))
    legend(fovnames, 'location', 'best')
    xlabel('wavenumber')
    ylabel('radiance')
    grid on; zoom on

  end % switch
end % err_plot

