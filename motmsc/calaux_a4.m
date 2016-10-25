%
% spec2igm demos, run from inside calmain_a4
%

specXX = specIT - specSP;

igmIT = spec2igm(specIT, inst);
igmSP = spec2igm(specSP, inst);
igmXX = spec2igm(specXX, inst);

%----------------------------
% interferograms and spectra
%----------------------------

figure(1); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(2,2,1)
ix = 1:inst.npts;
plot(ix, real(igmIT), ix, imag(igmIT))
title([inst.band, ' ICT interferograms'])
xlabel('index')
ylabel('volts')
grid on; zoom on

subplot(2,2,2)
ix = 1:inst.npts;
plot(ix, real(igmSP), ix, imag(igmSP))
title([inst.band, ' space-look interferograms'])
xlabel('index')
ylabel('volts')
grid on; zoom on

subplot(2,2,3)
x = inst.freq;
plot(x, real(specIT), x, imag(specIT))
% plot(x, abs(specIT))
title([inst.band, ' ICT spectra'])
xlabel('frequency')
ylabel('volts')
grid on; zoom on

subplot(2,2,4)
x = inst.freq;
plot(x, real(specSP), x, imag(specSP))
% plot(x, abs(specSP))
title([inst.band, ' space-look spectra'])
xlabel('frequency')
ylabel('volts')
grid on; zoom on

%--------------------------
% spectral complex modulus 
%--------------------------

meanIT = mean(abs(specIT))';
meanSP = mean(abs(specSP))';
meanXX = mean(abs(specXX))';

figure(2)
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(2,1,1)
x = inst.freq;
plot(x, abs(specXX), user.v1, meanXX, 'ok')
title([inst.band, ' ICT - SP spectra complex modulus'])
legend(fovnames, 'location', 'northeast')
text(0.97*user.v1, 1.2*max(meanXX), 'mean')
xlabel('frequency')
ylabel('volts')
grid on; zoom on

subplot(2,1,2)
x = inst.freq;
plot(x, abs(specSP), user.v1, meanSP, 'ok')
title([inst.band, ' space-look spectra complex modulus'])
legend(fovnames, 'location', 'northeast')
text(0.97*user.v1, 1.2*max(meanSP), 'mean')
xlabel('frequency')
ylabel('volts')
grid on; zoom on

'    [meanXX, meanSP, Vinst]'
[meanXX, meanSP, Vinst]

