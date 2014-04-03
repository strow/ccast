%
% ccast_mean - compare ccast FOV means over a set of files
%
% specify a directory and find the mean brightness temp for each FOV
% over all files, for a specific FOR.  compare mean values with FOV 5.
%
% works for both regular and high res data.  the call to inst_params
% is just to get the user grid.
%

addpath ./utils
addpath ../source

% test parameters
band = 'LW';
iFOR = 15;      % field of regard (1-30)
adflag = 1;     % ascending/descending flag

% path to SDR year
% syear = '/asl/data/cris/ccast/sdr60_hr/2013'
  syear = '/asl/data/cris/ccast/sdr60/2014'

% SDR days of the year
% sdays = 239 : 240;  % for high-res 2
  sdays = 60 : 62;

% get user grid and initialize outputs
[inst, user] = inst_params(band, 773.13);
nchan = round((user.v2 - user.v1) / user.dv) + 1;
vgrid = user.v1 + (0:nchan-1) * user.dv;
bavg = zeros(nchan * 9, 1);
navg = 0;

% loop on days
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

    % get data and frequency grid for this band
    switch(band)
      case 'LW', rtmp = rLW; vtmp = vLW;
      case 'MW', rtmp = rMW; vtmp = vMW;
      case 'SW', rtmp = rSW; vtmp = vSW;
    end

    % keep the standard user grid
    [m, n, k, nscan] = size(rtmp);
    [ix, jx] = seq_match(vgrid, vtmp);
    if ~isclose(vgrid, vtmp(jx))
      error('frequency grid mismatch')
    end

    keyboard

    % get BT, reshape for moving averages
    rtmp = squeeze(rtmp(jx, :, iFOR, :));
    btmp = real(rad2bt(vgrid, rtmp));
    btmp = reshape(btmp, nchan * 9, nscan);

    % loop on good scans
    for j = 1 : nscan
      if geo.Asc_Desc_Flag(j) ~= adflag
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
title(sprintf('UMBC %s mean, all FOVs, FOR %s %s', band, sFOR, adstr))
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

saveas(gcf, sprintf('umbc_%s_avg_FOR_%s_%s', band, sFOR, adstr), 'fig')

figure(2); clf
subplot(2,1,1)
plot(vgrid, bavg(:,[1,3,7,9]) - bavg(:,5)*ones(1,4));
ax = axis; ax(3) = -.4; ax(4) = .4; axis(ax)
legend('FOV 1', 'FOV 3', 'FOV 7', 'FOV 9', 'location', 'northeast')
title(sprintf('UMBC %s corner FOVs minus FOV 5, FOR %s %s', band, sFOR, adstr))
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

subplot(2,1,2)
plot(vgrid, bavg(:,[2,4,6,8]) - bavg(:,5)*ones(1,4));
ax = axis; ax(3) = -.4; ax(4) = .4; axis(ax)
legend('FOV 2', 'FOV 4', 'FOV 6', 'FOV 8', 'location', 'northeast')
title('side FOVs  minus FOV 5')
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

saveas(gcf, sprintf('umbc_%s_dif_FOR_%s_%s', band, sFOR, adstr), 'fig')

