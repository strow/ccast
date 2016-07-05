%
% cal_test2 -- match kcarta, rtp, and cris SDR obs
%

addpath /asl/matlib/h4tools
addpath /asl/packages/airs_decon/source
addpath ../source
addpath ../motmsc/time
addpath ../motmsc/utils

% load the CrIS SDR granule
% tstr = 'sdr60_hr';
  tstr = 'h3noaa4';
% tstr = 'h3a2new';
% tstr = input('test > ', 's');
gran = 'SDR_d20160120_t0304487';
fstr = fullfile('/asl/data/cris/ccast', tstr, '2016/020', gran);
d1 = load(fstr);

% load the RTP clear matchups
rtpfile = '/asl/s1/motteler/kctest5/clear_testY.rtp';
[h, ha, p, pa] = rtpread(rtpfile);

% load convolved kcarta data
% filt = 'resp';
  filt = 'flat';
% filt = input('filt > ', 's');
d2 = load(['cal_', filt]);

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
          && isclose(stime(iFOR, iSCAN), p.rtime(k), 20)
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
bobs = []; bcal = []; 
aobs = []; acal = [];
nfovs = zeros(9, 1);

% loop on FOVs
for jFOV = 1 : 9

  % index for current FOV
  iy = find(ismember(p.ifov, jFOV));
  ix = find(p.ifov == jFOV);
  if ~isequal(ix, iy), keyboard, end
  nfovs(jFOV) = length(ix);

  % mean and mean apodized brightness temps
  bobsLW = mean(real(rad2bt(vobsLW, robsLW(:, ix))), 2);
  bobsMW = mean(real(rad2bt(vobsMW, robsMW(:, ix))), 2);
  bobsSW = mean(real(rad2bt(vobsSW, robsSW(:, ix))), 2);

  bcalLW = mean(real(rad2bt(vcalLW, rcalLW(:, ix))), 2);
  bcalMW = mean(real(rad2bt(vcalMW, rcalMW(:, ix))), 2);
  bcalSW = mean(real(rad2bt(vcalSW, rcalSW(:, ix))), 2);

  aobsLW = mean(real(rad2bt(vobsLW, hamm_app(robsLW(:, ix)))), 2);
  aobsMW = mean(real(rad2bt(vobsMW, hamm_app(robsMW(:, ix)))), 2);
  aobsSW = mean(real(rad2bt(vobsSW, hamm_app(robsSW(:, ix)))), 2);

  acalLW = mean(real(rad2bt(vcalLW, hamm_app(rcalLW(:, ix)))), 2);
  acalMW = mean(real(rad2bt(vcalMW, hamm_app(rcalMW(:, ix)))), 2);
  acalSW = mean(real(rad2bt(vcalSW, hamm_app(rcalSW(:, ix)))), 2);

 % concatenate bands, save current FOV
  bobs = [bobs, [bobsLW; bobsMW; bobsSW]];
  bcal = [bcal, [bcalLW; bcalMW; bcalSW]];
  aobs = [aobs, [aobsLW; aobsMW; aobsSW]];
  acal = [acal, [acalLW; acalMW; acalSW]];

end

% concatenate grids
vobs = [vobsLW; vobsMW; vobsSW];

% clear d1 d2 
% clear h ha p pa 
% clear rcalLW rcalMW rcalSW robsLW robsMW robsSW

% save matchup data
sname = sprintf('cal_%s_%s', tstr, filt);
% save(sname, 'vobs', 'bobs', 'bcal', 'aobs', 'acal', ...
%             'tstr', 'filt', 'nfovs')

% plot setup
fname = fovnames;
fcolor = fovcolors;
pstr = strrep(tstr, '_', '-');

% summary plots
figure(1); clf
subplot(2,1,1)
set(gcf, 'DefaultAxesColorOrder', fcolor);
plot(vobs, bobs - bcal)
axis([600, 2600, -4, 4])
legend(fname, 'location', 'eastoutside')
title(sprintf('test %s obs minus %s calc, all FOVs', pstr, filt))
ylabel('dBT')
grid on; zoom on

subplot(2,1,2)
set(gcf, 'DefaultAxesColorOrder', fcolor);
plot(vobs, (bobs - bcal) - (aobs - acal))
axis([600, 2600, -4, 4])
legend(fname, 'location', 'eastoutside')
title(sprintf('test %s double difference, all FOVs', pstr))
xlabel('wavenumber')
ylabel('dBT')
grid on; zoom on

% residuals by FOV
figure(2); clf
stmp = strrep(tstr, '_', '-');
dd = mean(bobs(3:710,:) - bcal(3:710,:));
bar(dd);
xlabel('FOV')
ylabel('mean difference')
title(sprintf('%s minus %s by FOV', stmp, filt))
grid on

saveas(gcf, sprintf('LW_%s_%s', stmp, filt), 'png')

