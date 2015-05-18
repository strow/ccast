%
% noaa_test4 - try to match convolved and rtp radiances
%

addpath /home/motteler/mot2008/hdf/h4tools

testdir = '/asl/s1/motteler/data/noaa_test';

rtpfile = fullfile(testdir, 'rtp_d20150218_t0318115.rtp');

[h, ha, p, pa] = rtpread(rtpfile);

d1 = load('test3_flat');

btLW = rad2bt(d1.frqLW, d1.radLW);
btMW = rad2bt(d1.frqMW, d1.radMW);
btSW = rad2bt(d1.frqSW, d1.radSW);
btRTP = rad2bt(h.vchan, p.rcalc);

[ixLW, jxLW] = seq_match(h.vchan, d1.frqLW);
[ixMW, jxMW] = seq_match(h.vchan, d1.frqMW);
[ixSW, jxSW] = seq_match(h.vchan, d1.frqSW);

vmin = ones(2479, 1) * NaN;
imin = ones(2479, 1) * NaN;

% loop on kcarta rad
for j = 1 : 2479;

% t2 = rms(btLW(jxLW, j) * ones(1, 16200) - btRTP(ixLW, :)) + ...
%      rms(btMW(jxMW, j) * ones(1, 16200) - btRTP(ixMW, :)) + ...
%      rms(btSW(jxSW, j) * ones(1, 16200) - btRTP(ixSW, :));

  t2 = rms(btLW(jxLW, j) * ones(1, 16200) - btRTP(ixLW, :)) + ...
       rms(btMW(jxMW, j) * ones(1, 16200) - btRTP(ixMW, :));

  [vmin(j), imin(j)] = min(t2);
  
  if mod(j, 100) == 0, fprintf(1, '.'), end
end
fprintf(1, '\n')

save test4 vmin imin

