
% print summary phase stats from bcast dump files

% some high res files
% load /home/motteler/cris/data/2012/054/DMP_d20120223_t0033314.mat
load /home/motteler/cris/data/2012/054/DMP_d20120223_t0353302.mat

% some regular files
% load /home/motteler/cris/data/2012/058/DMP_d20120227_t0728566.mat
% load /home/motteler/cris/data/2012/112/DMP_d20120421_t0041415.mat
% load /home/motteler/cris/data/2012/128/DMP_d20120507_t0111317.mat

% specify FOV and FOR
FOV = 5;
FOR = 16;

% get obs index for selected FOR
iobs = find(igmFOR == FOR);

% plot all IGM obs for the selected FOR and FOV
figure(1); clf
subplot(2,1,1)
plot(1:instMW.npts+2, real(squeeze(igmMW(:, FOV, iobs))))
title(sprintf('Interferogram real components, FOV %d FOR %d', FOV, FOR))
xlabel('index')
ylabel('count')
grid on; zoom on

subplot(2,1,2)
plot(1:instMW.npts+2, imag(squeeze(igmMW(:, FOV, iobs))))
title(sprintf('Interferogram imag components, FOV %d FOR %d', FOV, FOR))
xlabel('index')
ylabel('count')
grid on; zoom on

% plot all spect obs for the selected FOR and FOV
figure(2)
subplot(2,1,1)
plot(instMW.freq, real(squeeze(rcMW(:, FOV, iobs))))
title(sprintf('Spectral real components, FOV %d FOR %d', FOV, FOR))
xlabel('wavenumber')
ylabel('count')
grid on; zoom on

subplot(2,1,2)
plot(instMW.freq, imag(squeeze(rcMW(:, FOV, iobs))))
title(sprintf('Spectral imag components, FOV %d FOR %d', FOV, FOR))
xlabel('wavenumber')
ylabel('count')
grid on; zoom on

% plot phase angles for the selected FOR and FOV
figure(3); clf
subplot(2,1,1)
r1 = squeeze(rcMW(:, FOV, iobs));
t1 =  atan(imag(r1)./real(r1));
plot(instMW.freq, t1)
title(sprintf('phase angle all obs, FOV %d FOR %d', FOV, FOR))
xlabel('wavenumber')
ylabel('radians')
grid on; zoom on

subplot(2,1,2)
t2 =  mean(t1, 2);
plot(instMW.freq, t2)
title(sprintf('mean phase angle, FOV %d FOR %d', FOV, FOR))
xlabel('wavenumber')
ylabel('radians')
grid on; zoom on

% saveas(gcf, sprintf('%s_FOR_%d', rid, FOR), 'png')
% saveas(gcf, sprintf('%s_FOR_%d', rid, FOR), 'fig')
% freq = instMW.freq;
% save(sprintf('%s_FOR_%d', rid, FOR), 'freq', 't2');

% atan2 test
% t2 = atan2(imag(rcMW(:, FOV, iobs)), real(rcMW(:, FOV, iobs)));
% t2 = unwrap(t2);
% plot(instMW.freq, t1, instMW.freq, t2)
% legend('atan', 'atan2', 'location', 'best')

