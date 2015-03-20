%
% rtp_test -- basic high level tests of ccast2rtp
%

% high res test file
sfile = '/asl/data/cris/ccast/sdr60_hr/2015/032/SDR_d20150201_t0704280.mat';

% low res test file
% sfile = '/asl/data/cris/ccast/sdr60/2014/002/SDR_d20140102_t2053431.mat';

% set the number of output guard channels
nguard = 2;

% set the number of sarta guard channels
sguard = 4;

% do the test
[head, hattr, prof, pattr] = ccast2rtp(sfile, nguard, sguard);

% sample radiance plot
figure(1); clf
[m, nobs] = size(prof.robs1);
k = max(1, floor(nobs/20));
v = head.vchan;
r = prof.robs1(:, 1:k:nobs);
plot(v, real(rad2bt(v, r)))
title('sample CrIS RTP data')
xlabel('wavenumber')
ylabel('BT in K')
grid on; zoom on

% ichan and vchan
figure(2); clf
subplot(2,1,1)
plot(head.ichan)
grid on; zoom on
title('ichan')
ylabel('index')
subplot(2,1,2)
plot(head.vchan)
title('vchan')
xlabel('index')
ylabel('wavenum')
grid on; zoom on

