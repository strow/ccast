%
% cal_test4 -- match kcarta, rtp, and cris SDR obs
%
% this version is for new (2017) nonlinearity tests
%

addpath /asl/matlib/h4tools
addpath /asl/packages/airs_decon/source
addpath ../source
addpath ../motmsc/time
addpath ../motmsc/utils

% load the CrIS SDR granule
% tstr = 'h3a2new';
% tstr = 'quad_070a';  % UMBC new a2 0.70 * all FOVs
% tstr = 'newUWMWa2';  % 2016 UW a2, MW only
% tstr = 'sdr60_hr';
tstr = input('test dir > ', 's')
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

% initialize output
nLW = length(vobsLW); nMW = length(vobsMW);
bobsLW = zeros(nLW, 9); bcalLW = zeros(nLW, 9); 
bobsMW = zeros(nMW, 9); bcalMW = zeros(nMW, 9); 
nfovs = zeros(9, 1);

% loop on FOVs
for jFOV = 1 : 9

  % index for current FOV
  ix = find(p.ifov == jFOV);
  nfovs(jFOV) = length(ix);

  % tabulate mean brightness temps
  bobsLW(:, jFOV) = mean(real(rad2bt(vobsLW, robsLW(:, ix))), 2);
  bcalLW(:, jFOV) = mean(real(rad2bt(vcalLW, rcalLW(:, ix))), 2);
  bobsMW(:, jFOV) = mean(real(rad2bt(vobsMW, robsMW(:, ix))), 2);
  bcalMW(:, jFOV) = mean(real(rad2bt(vcalMW, rcalMW(:, ix))), 2);
end

% residuals
resLW = bobsLW - bcalLW;
resMW = bobsMW - bcalMW;

ddifLW = resLW - (mean(resLW, 2) * ones(1, 9));
ddifMW = resMW - (mean(resMW, 2) * ones(1, 9));

% string for plot titles
tplot = strrep(tstr, '_', ' ')

figure(1);
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
subplot(2,1,1)
plot(vobsMW, resMW, 'linewidth', 2)
plot(vobsMW, resMW)
% axis([1690, 1710, -0.5, 1.2])
title(sprintf('%s minus calc', tplot))
legend(fovnames, 'location', 'eastoutside')
xlabel('wavenumber')
ylabel('dTb')
grid on; zoom on

subplot(2,1,2)
plot(vobsMW, ddifMW)
axis([1200, 1800, -1, 1])
% plot(vobsMW, ddifMW, 'linewidth', 2)
% axis([1200, 1800, -1.2, 0.6])
% axis([1620, 1660, -0.6, 0.4])
% axis([1690, 1710, -0.6, 0.4])
title(sprintf('%s double difference', tplot))
legend(fovnames, 'location', 'eastoutside')
xlabel('wavenumber')
ylabel('dTb')
grid on; zoom on
