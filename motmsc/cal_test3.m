%
% cal_test3 -- match kcarta, rtp, and cris SDR obs
%

addpath /asl/matlib/h4tools
addpath ../source
addpath ../motmsc/time
addpath ../motmsc/utils

% load the CrIS SDR granule
% tstr = 'sdr60_hr';
  tstr = 'e5_Pn_ag';
gran = 'SDR_d20150218_t0318115';
fstr = fullfile('/asl/data/cris/ccast', tstr, '2015/049', gran);
d1 = load(fstr);

% load the RTP clear matchups
rtpfile = '/asl/s1/motteler/kctest2/test_clear.rtp';
[h, ha, p, pa] = rtpread(rtpfile);

% load convolved kcarta data
d2 = load('cal_test2');
rstr = 'flat';

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

% get mean and filtered brightness temps
tobsLW = mean(real(rad2bt(vobsLW, robsLW)), 2);
tobsMW = mean(real(rad2bt(vobsMW, robsMW)), 2);
tobsSW = mean(real(rad2bt(vobsSW, robsSW)), 2);

tcalLW = mean(real(rad2bt(vcalLW, rcalLW)), 2);
tcalMW = mean(real(rad2bt(vcalMW, rcalMW)), 2);
tcalSW = mean(real(rad2bt(vcalSW, rcalSW)), 2);

gobsLW = mean(real(rad2bt(vobsLW, gauss_filt(robsLW))), 2);
gobsMW = mean(real(rad2bt(vobsMW, gauss_filt(robsMW))), 2);
gobsSW = mean(real(rad2bt(vobsSW, gauss_filt(robsSW))), 2);

gcalLW = mean(real(rad2bt(vcalLW, gauss_filt(rcalLW))), 2);
gcalMW = mean(real(rad2bt(vcalMW, gauss_filt(rcalMW))), 2);
gcalSW = mean(real(rad2bt(vcalSW, gauss_filt(rcalSW))), 2);

% concatenate bands
vobs = [vobsLW; vobsMW; vobsSW];
tobs = [tobsLW; tobsMW; tobsSW];
tcal = [tcalLW; tcalMW; tcalSW];
gobs = [gobsLW; gobsMW; gobsSW];
gcal = [gcalLW; gcalMW; gcalSW];

clear d1 d2 
clear h ha p pa 
clear rcalLW rcalMW rcalSW robsLW robsMW robsSW

pstr = strrep(tstr, '_', '-');

figure(1); clf
subplot(2,1,1)
plot(vobs, tobs - tcal)
axis([600, 2600, -2, 2])
title(sprintf('test %s obs minus %s calc, all FOVs', pstr, rstr))
ylabel('dBT')
grid on; zoom on

subplot(2,1,2)
plot(vobs, (tobs - tcal) - (gobs - gcal))
axis([600, 2600, -2, 2])
title('double difference, all FOVs')
xlabel('wavenumber')
ylabel('dBT')
grid on; zoom on

