%
% find_anom3 -- FOV 5 anomaly tabulated values
%

addpath ../source
addpath ../motmsc/utils

%-----------------
% test parameters
%-----------------
sFOR = 15:16;  % fields of regard, 1-30

% path to SDR year
tstr1 = 'sdr60_hr';
tstr2 = 'ES_scaled';
syear1 = fullfile('/asl/data/cris/ccast', tstr1, '2016');
syear2 = fullfile('/asl/data/cris/ccast', tstr2, '2016');

% SDR days of the year
% sdays =  18 : 20;
  sdays = 20;

% tabulated results
TbTab = [];
ESTab = [];
t900Tab = [];
diffTab = [];
scanTab = [];
forTab = [];
ridTab = [];

%------------------------
% loop on days and files
%------------------------
for di = sdays

  % loop on SDR files
  doy = sprintf('%03d', di);
  flist1 = dir(fullfile(syear1, doy, 'SDR*.mat'));
  flist2 = dir(fullfile(syear2, doy, 'SDR*.mat'));

  for fi = 1 : length(flist1);

    % load the SDR data
    rid = flist1(fi).name(5:22);
    stmp = ['SDR_', rid, '.mat'];
    sfile1 = fullfile(syear1, doy, stmp);
    sfile2 = fullfile(syear2, doy, stmp);
    d1 = load(sfile1);
    d2 = load(sfile2);

    % loop on scans
    [t1, t2, t3, nscan] = size(d1.rLW);
    for j = 1 : nscan

      % loop on selected FORs
      for i = sFOR
        if d1.L1a_err(i, j)
          continue
        end
        if ~isempty(find(isnan(d1.rLW(:, :, i, j))))
          continue
        end

        % selected brightness temps
        ix = [1:4, 6:9];
        TbLW = real(rad2bt(d1.vLW, d1.rLW(:, :, i, j)));
        t668fov5 = TbLW(32, 5);
        t668not5 = mean(TbLW(32, ix));
        t900mean = mean(TbLW(403, :));
        maxdiff = fovdiff(TbLW);

        % selected radiances
        r668fov5 = d1.rLW(32, 5, i, j);
        r668not5 = mean(d1.rLW(32, ix, i, j));

        % radiance integrals
        int_all = mean(d1.rLW(:, :, i, j));
        int_fov5 = int_all(5);
        int_not5 = mean(int_all(ix));

        if t900mean <= 230
          TbTab = cat(3, TbTab, TbLW);
          ESTab = cat(3, ESTab, d2.rLW(:,:,i,j) + 1i * d2.cLW(:,:,i,j));
          t900Tab = [t900Tab, t900mean];
          diffTab = [diffTab, maxdiff];          
          scanTab = [scanTab, j];
          forTab = [forTab, i];          
          ridTab = [ridTab; rid];          

        end

      end % loop on selected FORs
    end % loop on scans

    if mod(fi, 10) == 0, fprintf(1, '.'), end
  end
  fprintf(1, '\n')
end

vLW = d1.vLW;

save find_anom3 vLW TbTab ESTab t900Tab diffTab scanTab forTab ridTab 

return

[dt, ix] = min(diffTab);
scanTab(ix)
forTab(ix)
ridTab(ix, :)

ix = find(t900Tab < 220); 
ifov = 1
figure(ifov)
subplot(2,1,1)
plot(vLW, abs(squeeze(ESTab(:, ifov, ix))))
axis([660, 680, -1, 1])
title(sprintf('FOV %d ES with window < 220K', ifov))
xlabel('frequency')
ylabel('Volts')
grid on

subplot(2,1,2)
plot(vLW, abs(squeeze(TbTab(:, ifov, ix))))
axis([660, 680, 180, 280])
title(sprintf('FOV %d calibrated brightness temps', ifov))
xlabel('frequency')
ylabel('Tb, K')
grid on

return  % select figures below as needed

figure(1); clf
plot(aTab(:, 1), aTab(:, 2) - aTab(:, 3), '.')
title('FOV 5 minus mean of other FOVs at 668 cm-1')
axis([180, 320, -3, 4])
xlabel('mean 900 cm-1 BT')
ylabel('668 cm-1 temp diff')
grid on; zoom on
% saveas(gcf, 'FOV_5_basic_anom', 'png')

figure(2); clf
plot(aTab(:, 1), aTab(:, 4) ./ aTab(:, 5), '.')
title('FOV 5 / mean of other FOVs at 668 cm-1')
axis([180, 320, 0.96, 1.06])
xlabel('mean 900 cm-1 temp')
ylabel('668 cm-1 radiance ratio')
grid on; zoom on
% saveas(gcf, 'FOV_5_ratio_anom', 'png')

figure(3); clf
plot(aTab(:, 1), aTab(:, 6) ./ aTab(:, 7), '.')
title('FOV 5 integral / mean of other FOV integrals')
axis([180, 320, 0.4, 1.6])
xlabel('mean 900 cm-1 temp')
ylabel('integral ratio')
grid on; zoom on
% saveas(gcf, 'FOV_5_integral_ratio', 'png')

figure(4); clf
plot(aTab(:, 1), aTab(:, 8) ./ aTab(:, 9), '.')
title('FOV 5 DC lev int / mean of other FOVs DC lev int')
axis([180, 320, 0.4, 1.6])
xlabel('mean 900 cm-1 temp')
ylabel('integral ratio')
grid on; zoom on
% saveas(gcf, 'FOV_5_dc_lev_int_ratio', 'png')

figure(5); clf
% original selection criteria
% ix = aTab(:, 10) < 1 & (aTab(:, 1) < 230 | aTab(:, 1) > 270);
ix = aTab(:, 10) < 1;
plot(aTab(ix, 1), aTab(ix, 8) ./ aTab(ix, 9), '*')
% title('DC level integral ratio, original test set')
title('DC level integral ratio, homogeneous test set')
axis([220, 320, 1.06, 1.1])
xlabel('mean 900 cm-1 temp')
ylabel('integral ratio')
grid on; zoom on
% saveas(gcf, 'FOV_5_dc_lev_int_orig', 'png')

% DC level integral vs window chan temp
figure(6); clf
% mean of all fovs:
x1 = aTab(:, 1);
y1 = aTab(:, 8);
y2 = aTab(:, 9); 
y3 = ((1/9)*y1 + (8/9)*y2);

subplot(2,1,1)
plot(x1, y3, '.')
axis([180, 320, 0, 0.6])
title('DC level integral vs 900 cm-1 temp')
legend('mean all FOVs', 'location', 'northwest')
ylabel('Volts')
grid on; zoom on

subplot(2,1,2)
plot(x1, y1, '.r', x1, y2, '.g')
axis([180, 320, 0, 0.6])
legend('FOV 5 only', 'mean other FOVs', 'location', 'northwest')
xlabel('mean 900 cm-1 BT')
ylabel('Volts')
grid on; zoom on
% saveas(gcf, 'dc_lev_vs_window', 'png')

