%
% nlc_stats_MW - multi-day stats from nlc values
%
% rows of aTab are FORs  
% cols of aTab are as follows
% 
% index  var name      description
% -------------------------------------------
%   1    int_fov7   radiance integral FOV 7
%   2    int_fov9   radiance integral FOV 9
%   3    int_mean   radiance integral mean all FOVs
%   4    lev_fov7   dc level integral FOV 7
%   5    lev_fov9   dc level integral FOV 9
%   6    lev_mean   dc level  integral mean all FOVs
%   7    maxdiff    max RMS FOV difference
%

addpath ../source
addpath ../motmsc/utils

%-----------------
% test parameters
%-----------------
sFOR = 15:16;  % fields of regard, 1-30

% path to SDR year
tstr = 'sdr60_nlc';
syear = fullfile('/asl/data/cris/ccast', tstr, '2016');

% SDR days of the year
sdays =  1 : 3;

% 
aTab = [];

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

    Mkeyboard
    [t1, t2, t3, nscan] = size(rMW);
    aTmp = zeros(length(sFOR)*nscan, 7);
    k = 0;

    % loop on scans
    for j = 1 : nscan

      % loop on selected FORs
      for i = sFOR
        if L1a_err(i, j)
          continue
        end
        if ~isempty(find(isnan(rMW(:, :, i, j))))
          continue
        end

        % selected brightness temps
        bMW = real(rad2bt(vMW, rMW(:, :, i, j)));
        maxdiff = fovdiff(bMW);

        % radiance integrals
        int_all = mean(rMW(:, :, i, j));
        int_fov7 = int_all(7);
        int_fov9 = int_all(9);
        int_mean = mean(int_all);

        % DC level integrals
        lev_all = nMW(:, i, j);
        lev_fov7 = lev_all(5);
        lev_fov9 = lev_all(5);
        lev_mean = mean(lev_all(ix));

        k = k + 1;
        aTmp(k, 1) = int_fov7;
        aTmp(k, 2) = int_fov9;
        aTmp(k, 3) = int_mean;
        aTmp(k, 4) = lev_fov7;
        aTmp(k, 5) = lev_fov9;
        aTmp(k, 6) = lev_mean;
        aTmp(k, 7) = maxdiff;

      end % loop on selected FORs
    end % loop on scans

    aTab = [aTab; aTmp(1:k, :)];

    if mod(fi, 10) == 0, fprintf(1, '.'), end
  end
  fprintf(1, '\n')
end

save nlc_stats_MW aTab sFOR syear sdays

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

