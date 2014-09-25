% 
% ils_test3 -- show ILS change at cutpoints
%

% select a FOV
iFOV = 1;

% channel for comparison plots
ichan = 300;  

% set interferometric params
band = 'SW';

% high res SW step
w1 = 773.1;   % 773.150 or less
% w2 = 773.151; % small resid
w2 = 773.152; % big resid

wppm = round(1e6 * (w2 - w1) / w1)

opts = struct;
opts.resmode = 'hires2';

inst1 = inst_params(band, w1, opts);
inst2 = inst_params(band, w2, opts);

n = inst1.npts;
smat1 = zeros(n, n);
smat2 = zeros(n, n);

opt2 = struct;
opt2.wrap = 'psinc n';
opt2.narc = 2000;

for i = 1 : n;
  smat1(:, i) = newILS(iFOV, inst1, inst1.freq(i), inst1.freq, opt2);
  smat2(:, i) = newILS(iFOV, inst2, inst2.freq(i), inst2.freq, opt2);
  if mod(i, 20) == 0, fprintf(1, '.'), end
end
fprintf(1, '\n')

maxdif = max(smat1 - smat2);
mindif = min(smat1 - smat2);

figure(1); clf
freq = inst1.freq;
plot(freq, maxdif, freq, mindif)
% title(sprintf('min and max ILS diffs for %d ppm shift', wppm))
title(sprintf('ILS diffs for wlaser at %7.3f and %7.3f nm', w1, w2))
legend('max diff', 'min diff', 'location', 'southeast')
xlabel('ILS by channel freq')
ylabel('residual')
grid on; zoom on 

figure(2); clf
freq = inst1.freq;
ix = find(freq(ichan) - 10 <= freq & freq <= freq(ichan) + 9);
subplot(2,1,1)
plot(freq(ix), smat1(ix, ichan))
title(sprintf('ILS %d for wlaser at %7.3f', ichan, w1))
ylabel('weight')
grid on; zoom on 
subplot(2,1,2)
plot(freq(ix), smat1(ix, ichan) - smat2(ix, ichan))
title(sprintf('ILS diff for wlaser at %7.3f and %7.3f nm', w1, w2))
xlabel('wavenumber')
ylabel('residual')
grid on; zoom on 

