%
% idps_mean - compare idps FOV means over a set of files
%
% specify a directory and find the mean brightness temp for each FOV
% over all files, for a specific FOR.  Compare mean values with FOV 5.
%
% the call to inst_params is just to get the user grid.
%

addpath ./asl
addpath ./utils
addpath ../source

% test parameters
band = 'LW';
iFOR = 15;      % field of regard (1-30)
adflag = 1;     % ascending/descending flag

% path to SDR year
syear = '/asl/data/cris/sdr60/hdf/2014';

% SDR days of the year
sdays = 60 : 62;

% get user grid and initialize outputs
[inst, user] = inst_params(band, 773.13);
nchan = round((user.v2 - user.v1) / user.dv) + 1;
vgrid = user.v1 + (0:nchan-1) * user.dv;
bavg = zeros(nchan * 9, 1);
navg = 0;

% IDPS SDR channel frequencies
wn_lw = linspace(650-0.625*2,1095+0.625*2,717)';
wn_mw = linspace(1210-1.25*2,1750+1.25*2,437)';
wn_sw = linspace(2155-2.50*2,2550+2.50*2,163)';

% loop on days
for di = sdays

  % loop on SDR files
  doy = sprintf('%03d', di);
  flist = dir(fullfile(syear, doy, ['SCRIS_npp_*.h5']));
  for fi = 1 : length(flist);

    % read the next SDR file
    sid = flist(fi).name(11:28);
    sfile = fullfile(syear, doy, flist(fi).name);
      try 
    pd = readsdr_rawpd(sfile);
    catch
      fprintf(1, 'could not read %s\n', sfile);
      continue
    end

    % read the corresponding geo file
    glist = dir(fullfile(syear, doy, ['GCRSO_npp_', sid, '*_noaa_ops.h5']));
    if isempty(glist)
      fprintf(1, 'no corresponding geo for %s\n', sid)
      continue
    end
    gtmp = glist(end).name;
    gfile = fullfile(syear, doy, gtmp);
    try
      [geo, gat1, gat2] = read_GCRSO(gfile);  
    catch
      fprintf(1, 'could not read %s\n', gfile);
      continue
    end

    % get data and frequency grid for this band
    switch(band)
      case 'LW', rtmp = pd.ES_RealLW; vtmp = wn_lw';
      case 'MW', rtmp = pd.ES_RealMW; vtmp = wn_mw';
      case 'SW', rtmp = pd.ES_RealSW; vtmp = wn_sw';
    end

    % keep the standard user grid
    [m, n, k, nscan] = size(rtmp);
    [ix, jx] = seq_match(vgrid, vtmp);
    if ~isclose(vgrid, vtmp(jx))
      error('frequency grid mismatch')
    end

    % get BT, reshape for moving averages
    rtmp = squeeze(rtmp(jx, :, iFOR, :));
    btmp = real(rad2bt(vgrid, rtmp));
    btmp = reshape(btmp, nchan * 9, nscan);

    % loop on scans
    for j = 1 : nscan
      k =  floor((j-1)/4) + 1;
      if gat2(k).Ascending_Descending_Indicator ~= adflag
        continue
      end
      if isempty(find(isnan(btmp(:, j))))
        [bavg, navg] = rec_mean(bavg, navg, btmp(:, j));
      end
    end
    fprintf(1, '.')
  end
  fprintf(1, '\n')
end

bavg = reshape(bavg, nchan, 9);
navg

% plot results
sFOR = sprintf('%d', iFOR);
if adflag == 1,  adstr = 'asc'; else, adstr = 'des'; end

figure(1); clf
subplot(2,1,1)
plot(vgrid, bavg);
legend(fovnames, 'location', 'southeast')
title(sprintf('IDPS %s mean, all FOVs, FOR %s %s', band, sFOR, adstr))
xlabel('wavenumber')
ylabel('BT, K')
grid on; zoom on

subplot(2,1,2)
plot(vgrid, bavg - bavg(:,5)*ones(1,9));
ax = axis; ax(3) = -.4; ax(4) = .4; axis(ax)
legend(fovnames, 'location', 'southeast')
title('all FOVs minus FOV 5')
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

saveas(gcf, sprintf('idps_%s_avg_FOR_%s_%s', band, sFOR, adstr), 'fig')

figure(2); clf
subplot(2,1,1)
plot(vgrid, bavg(:,[1,3,7,9]) - bavg(:,5)*ones(1,4));
ax = axis; ax(3) = -.4; ax(4) = .4; axis(ax)
legend('FOV 1', 'FOV 3', 'FOV 7', 'FOV 9', 'location', 'northeast')
title(sprintf('IDPS %s corner FOVs minus FOV 5, FOR %s %s', band, sFOR, adstr))
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

subplot(2,1,2)
plot(vgrid, bavg(:,[2,4,6,8]) - bavg(:,5)*ones(1,4));
ax = axis; ax(3) = -.4; ax(4) = .4; axis(ax)
legend('FOV 2', 'FOV 4', 'FOV 6', 'FOV 8', 'location', 'northeast')
title('side FOVs minus FOV 5')
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

saveas(gcf, sprintf('idps_%s_dif_FOR_%s_%s', band, sFOR, adstr), 'fig')

