%
%   ict_trends -- look at ICT daily mean over time
%

% ylist = 2014 : 2019;
  ylist = 2015 : 2018;
  dlist = 1 : 16 : 365;
% chome = '/asl/cris/ccast/sdr45_npp_HR';
  chome = '/asl/cris/ccast_umbc_a2_new_ict/sdr45_npp_HR';

addpath ../source
addpath ../motmsc/time
addpath ../motmsc/utils

ict_list = [];
% neon_list = [];
% wlaser_list = [];

dnum_list = [];

% loop on years
for yint = ylist

  % loop on days (of year)
  for doy = dlist

    % initialize daily lists
    ict_tmp = [];
%   neon_tmp = [];
%   wlaser_tmp = [];

    % loop on CrIS granules
    dstr = sprintf('%03d', doy);
    ystr = sprintf('%04d', yint);
    fprintf(1, '%s doy %s\n', ystr, dstr)
    glist = dir(fullfile(chome, ystr, dstr, 'CrIS_SDR*.mat'));

    for gi = 1 : length(glist);
      cgran1 = fullfile(glist(gi).folder, glist(gi).name);

      % read sci, eng and geo data
      d1 = load(cgran1, 'sci', 'eng', 'geo');
      
      % loop on scans
      for si = 1 : 45

        % geo subsetting (edit as needed)
        if d1.geo.Latitude(5,15,si) < 70, continue, end

        % get index of the closest sci record
        dt = abs(max(d1.geo.FORTime(:, si)) - ...
                 tai2iet(utc2tai([d1.sci.time]/1000)));
        ic = find(dt == min(dt));
        if isempty(ic), continue, end

        % get ICT temperature
        T_ICT = (d1.sci(ic).T_PRT1 + d1.sci(ic).T_PRT2) / 2;

        ict_tmp = [ict_tmp, T_ICT];
      end

%     neon = d1.eng.NeonCal.NeonGasWavelength;
%     wlaser = metlaser(d1.eng.NeonCal);

      % accumulate daily values
%     neon_tmp = [neon_tmp, neon];
%     wlaser_tmp = [wlaser_tmp, wlaser];
    end

    % add to daily lists
    ict_list = [ict_list, mean(ict_tmp)];
%   neon_list = [neon_list, mean(neon_tmp)];
%   wlaser_list = [wlaser_list, mean(wlaser_tmp)];
    dnum_list = [dnum_list, datenum(yint, 1, doy)];

  end
end

% save('ict_trends', 'ict_list', 'neon_list', 'wlaser_list', 'dnum_list');
  save('ict_trends', 'ylist', 'dlist', 'chome', 'ict_list', 'dnum_list');

dax = datetime(dnum_list, 'ConvertFrom', 'datenum');

figure(1); clf
plot(dax, ict_list, 'linewidth', 2)
% xlim([datetime('Dec 1, 2014'), datetime('Jan 1, 2018')])
title('ICT daily mean')
ylabel('degrees (K)')
grid on

% subplot(2,1,2)
% plot(dax, wlaser_list, 'linewidth', 2)
% xlim([datetime('Dec 1, 2014'), datetime('Jan 1, 2018')])
% title('metrology laser daily mean')
% ylabel('wavelength (nm)')
% xlabel('date')
% grid on

% subplot(3,1,2)
% plot(dax, neon_list, 'linewidth', 2)
% title('neon daily mean')
% ylim([703,704])
% ylabel('wavelength (nm)')
% grid on

