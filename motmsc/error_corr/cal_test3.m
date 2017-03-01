%
% cal_test3 - basic correlation stats for clear matchups
%
% basic correlation plots for a single FOV and all three bands
%

addpath /asl/matlib/h4tools
addpath /asl/packages/airs_decon/source
addpath ../source
addpath ../motmsc/time
addpath ../motmsc/utils

% load the CrIS SDR granule
% tstr = 'h3noaa4';
% tstr = 'sdr60_hr_t-20';
  tstr = 'sdr60_hr';
gran = 'SDR_d20160120_t0304487';
fstr = fullfile('/asl/data/cris/ccast', tstr, '2016/020', gran);
d1 = load(fstr);

% load the RTP clear matchups
rtpfile = '/asl/s1/motteler/kctest5/clear_testY.rtp';
[h, ha, p, pa] = rtpread(rtpfile);

% load convolved kcarta data
% d2 = load('cal_resp');
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

% use the intersection of frequency grids
[ix, jx] = seq_match(d1.vLW, d2.frqLW);
vobsLW = d1.vLW(ix);     vcalLW = d2.frqLW(jx); 
robsLW = robsLW(ix, :);  rcalLW = d2.radLW(jx, :);

[ix, jx] = seq_match(d1.vMW, d2.frqMW);
vobsMW = d1.vMW(ix);     vcalMW = d2.frqMW(jx); 
robsMW = robsMW(ix, :);  rcalMW = d2.radMW(jx, :);

[ix, jx] = seq_match(d1.vSW, d2.frqSW);
vobsSW = d1.vSW(ix);     vcalSW = d2.frqSW(jx); 
robsSW = robsSW(ix, :);  rcalSW = d2.radSW(jx, :);

% optional FOV subsetting
% ix = 1 : nobs;
jFOV = 1;
ix = find(p.ifov == jFOV);

% convert to brightness temps
bobsLW = real(rad2bt(vobsLW, robsLW(:, ix)));
bobsMW = real(rad2bt(vobsMW, robsMW(:, ix)));
bobsSW = real(rad2bt(vobsSW, robsSW(:, ix)));

bcalLW = real(rad2bt(vcalLW, rcalLW(:, ix)));
bcalMW = real(rad2bt(vcalMW, rcalMW(:, ix)));
bcalSW = real(rad2bt(vcalSW, rcalSW(:, ix)));

% compare with 10 May 2016 telecon plots
% plot(vcalLW, mean(bobsLW - bcalLW, 2))
% axis([650, 680, -1, 1])

% residuals
errLW = bobsLW - bcalLW;
errMW = bobsMW - bcalMW;
errSW = bobsSW - bcalSW;

% correlation
corLW = corrcoef(errLW');
corMW = corrcoef(errMW');
corSW = corrcoef(errSW');

% plots
load llsmap5

figure(1)
imagesc(vobsLW, vobsLW, corLW)
% axis([650, 730, 650, 730])
% caxis([-0.6, 0.6])
caxis([-1, 1])
title(sprintf('CrIS FOV %d LW error correlation', jFOV))
xlabel('wavenumber')
ylabel('wavenumber')
set(gca,'YDir','normal')
colormap(llsmap5)
colorbar
% saveas(gcf, sprintf('err_cor_fov%d_LW', jFOV), 'png')

figure(2)
imagesc(vobsMW, vobsMW, corMW)
caxis([-1, 1])
title(sprintf('CrIS FOV %d MW error correlation', jFOV))
xlabel('wavenumber')
ylabel('wavenumber')
set(gca,'YDir','normal')
colormap(llsmap5)
colorbar
% saveas(gcf, sprintf('err_cor_fov%d_MW', jFOV), 'png')

figure(3)
imagesc(vobsSW, vobsSW, corSW)
caxis([-1, 1])
title(sprintf('CrIS FOV %d SW error correlation', jFOV))
xlabel('wavenumber')
ylabel('wavenumber')
set(gca,'YDir','normal')
colormap(llsmap5)
colorbar
% saveas(gcf, sprintf('err_cor_fov%d_SW', jFOV), 'png')

