%
% cal_test5 - more detailed stats for clear matchups
%
% stats for clear matchup stats with FOV breakouts of both apodized
% and unapodized data, NEdT and correlation stats, and lots of plots
% of apodized data.
%

addpath /asl/matlib/h4tools
addpath /asl/packages/airs_decon/source
addpath ../source
addpath ../motmsc/time
addpath ../motmsc/utils

% load the CrIS SDR granule
% tstr = input('test dir > ', 's')
tstr = 'sdr60_hr';
gran = 'SDR_d20160120_t0304487';
fstr = fullfile('/asl/data/cris/ccast', tstr, '2016/020', gran);
d1 = load(fstr);

% load the RTP clear matchups
rtpfile = '/asl/s1/motteler/kctest5/clear_testY.rtp';
[h, ha, p, pa] = rtpread(rtpfile);

% load convolved kcarta data
d2 = load('cal_flat');

% match RTP and SDR obs
[m, nobs] = size(d2.radLW);
stime = iet2tai(d1.geo.FORTime);
robsLW = ones(length(d1.vLW), nobs) * NaN;
robsMW = ones(length(d1.vMW), nobs) * NaN;
robsSW = ones(length(d1.vSW), nobs) * NaN;
k = 1;
for iSCAN = 1 : 60
  for iFOR = 1 : 30
    for iFOV = 1 : 9
      if p.xtrack(k) == iFOR && p.ifov(k) == iFOV ...
          && isclose(stime(iFOR, iSCAN), p.rtime(k))
        robsLW(:, k) = d1.rLW(:, iFOV, iFOR, iSCAN);
        robsMW(:, k) = d1.rMW(:, iFOV, iFOR, iSCAN);
        robsSW(:, k) = d1.rSW(:, iFOV, iFOR, iSCAN);
        if k < nobs
          k = k + 1; 
        else 
          break
        end
      end
    end
  end
end

% move to a common grid
[ix, jx] = seq_match(d1.vLW, d2.frqLW);
vobsLW = d1.vLW(ix);     vcalLW = d2.frqLW(jx); 
robsLW = robsLW(ix, :);  rcalLW = d2.radLW(jx, :);

[ix, jx] = seq_match(d1.vMW, d2.frqMW);
vobsMW = d1.vMW(ix);     vcalMW = d2.frqMW(jx); 
robsMW = robsMW(ix, :);  rcalMW = d2.radMW(jx, :);

[ix, jx] = seq_match(d1.vSW, d2.frqSW);
vobsSW = d1.vSW(ix);     vcalSW = d2.frqSW(jx); 
robsSW = robsSW(ix, :);  rcalSW = d2.radSW(jx, :);

% convert to brightness temps
btobsLW = real(rad2bt(vobsLW, robsLW));
btobsMW = real(rad2bt(vobsMW, robsMW));
btcalLW = real(rad2bt(vcalLW, rcalLW));
btcalMW = real(rad2bt(vcalMW, rcalMW));
apobsLW = real(rad2bt(vobsLW, hamm_app(robsLW)));
apobsMW = real(rad2bt(vobsMW, hamm_app(robsMW)));
apcalLW = real(rad2bt(vcalLW, hamm_app(rcalLW)));
apcalMW = real(rad2bt(vcalMW, hamm_app(rcalMW)));

% differences
dbtobsLW = btobsLW - btcalLW;
dbtobsMW = btobsMW - btcalMW;
dapobsLW = apobsLW - apcalLW;
dapobsMW = apobsMW - apcalMW;

% tabulate mean and std by FOV
nvLW = length(vobsLW); nvMW = length(vobsMW);
mapobsLW = zeros(nvLW, 9);  sapobsLW = zeros(nvLW, 9);
mapobsMW = zeros(nvMW, 9);  sapobsMW = zeros(nvMW, 9);
mdbtobsLW = zeros(nvLW, 9); sdbtobsLW = zeros(nvLW, 9);
mdbtobsMW = zeros(nvMW, 9); sdbtobsMW = zeros(nvMW, 9);
mdapobsLW = zeros(nvLW, 9); sdapobsLW = zeros(nvLW, 9);
mdapobsMW = zeros(nvMW, 9); sdapobsMW = zeros(nvMW, 9);
nfovs = zeros(9, 1);

% loop on FOVs
for jFOV = 1 : 9

  % index for current FOV
  ix = find(p.ifov == jFOV);
  nfovs(jFOV) = length(ix);

  mapobsLW(:, jFOV) = mean(apobsLW(:, ix), 2);
  mapobsMW(:, jFOV) = mean(apobsMW(:, ix), 2);
  mdbtobsLW(:, jFOV) = mean(dbtobsLW(:, ix), 2);
  mdbtobsMW(:, jFOV) = mean(dbtobsMW(:, ix), 2);
  mdapobsLW(:, jFOV) = mean(dapobsLW(:, ix), 2);
  mdapobsMW(:, jFOV) = mean(dapobsMW(:, ix), 2);

  sapobsLW(:, jFOV) = std(apobsLW(:, ix), 0, 2);
  sapobsMW(:, jFOV) = std(apobsMW(:, ix), 0, 2);
  sdbtobsLW(:, jFOV) = std(dbtobsLW(:, ix), 0, 2);
  sdbtobsMW(:, jFOV) = std(dbtobsMW(:, ix), 0, 2);
  sdapobsLW(:, jFOV) = std(dapobsLW(:, ix), 0, 2);
  sdapobsMW(:, jFOV) = std(dapobsMW(:, ix), 0, 2);
end

% ccast measured NEdN
vLW = d1.vLW; vMW = d1.vMW;
nednLW = squeeze(mean(d1.nLW, 3)) * 0.63;
nednMW = squeeze(mean(d1.nMW, 3)) * 0.63;
% nedtLW = rad2bt(vLW, bt2rad(vLW, 280) + nednLW) - 280;
% nedtMW = rad2bt(vMW, bt2rad(vMW, 280) + nednMW) - 280;

% mean apodized obs as radiance
[ix, jx] = seq_match(vobsLW, vLW);
rtmpLW = bt2rad(vobsLW, mapobsLW);
nedtLW = rad2bt(vobsLW, rtmpLW + nednLW(jx,:)) - mapobsLW;

% correlation matrices
corLW = corrcoef(dapobsLW');

%---------------------
% correlation plots
%---------------------
load llsmap5
figure(1); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(1,2,1)
imagesc(vobsLW, vobsLW, corLW)
caxis([-1, 1])
title('LW residual correlation')
xlabel('wavenumber')
ylabel('wavenumber')
set(gca,'YDir','normal')
colormap(llsmap5)
colorbar

subplot(1,2,2)
imagesc(vobsLW, vobsLW, corLW)
axis([650, 730, 650, 730])
caxis([-1, 1])
title('LW correlaion detail')
xlabel('wavenumber')
% ylabel('wavenumber')
set(gca,'YDir','normal')
colormap(llsmap5)
colorbar

%---------------------
% residuals with NEdT
%---------------------
figure(2); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
plot(vobsLW, mean(nedtLW,2), vobsLW, mean(sdapobsLW,2), 'linewidth', 2)
axis([650, 1100, 0, 0.6])
title('LW apodized obs minus calc with NEdT')
legend('NEdT at mean obs', 'std(obs - calc)')
ylabel('dTb, K')
grid on; zoom on

% breakout residual std with instrument noise
figure(3); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
subplot(2,1,1)
plot(vobsLW, nedtLW)
axis([650, 1100, 0, 0.4])
title('LW apodized NEdT')
legend(fovnames, 'location', 'northeast')
ylabel('dTb, K')
grid on; zoom on

subplot(2,1,2)
plot(vobsLW, sdapobsLW)
axis([650, 1100, 0, 1])
title('LW std apodized obs minus calc')
legend(fovnames, 'location', 'northeast')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on

%----------------------
% basic residual stats
%----------------------
figure(4); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
subplot(2,1,1)
plot(vobsLW, mdapobsLW)
axis([650, 1100, -1, 0.5])
title('LW mean apodized obs minus calc')
legend(fovnames, 'location', 'eastoutside')
ylabel('dTb, K')
grid on; zoom on

subplot(2,1,2)
plot(vobsLW, sdapobsLW)
axis([650, 1100, 0, 1])
title('LW std apodized obs minus calc')
legend(fovnames, 'location', 'eastoutside')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on

%----------------------
% basic radiance stats
%----------------------
figure(5); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
subplot(2,1,1)
plot(vobsLW, mapobsLW)
axis([650, 1100, 200, 300])
title('LW mean apodized obs')
legend(fovnames, 'location', 'eastoutside')
ylabel('dTb')
grid on; zoom on

subplot(2,1,2)
plot(vobsLW, sapobsLW)
axis([650, 1100, 0, 4])
title('LW std apodized obs')
legend(fovnames, 'location', 'eastoutside')
xlabel('wavenumber')
ylabel('dTb')
grid on; zoom on

