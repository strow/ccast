
% load some high res data
load /home/motteler/cris/data/2012/054/DMP_d20120223_t1753255.mat

% get the bit trim mask
band = 'LW';
[mask, bmax, bmin] = hires_bitmask(band);

% specify FOV and FOR
FOV = 5;
FOR = 16;

% get obs index for selected FOR
iobs = find(igmFOR == FOR);

% plot all IGM obs for a given FOR and FOV
figure(1); clf
subplot(2,1,1)
x = 1:instLW.npts+2;
y = real(squeeze(igmLW(:, FOV, iobs)));
plot(x, y, x, bmin, x, bmax);
title(sprintf('Interferogram real components, FOV %d FOR %d', FOV, FOR))
xlabel('index')
ylabel('count')
grid on; zoom on

subplot(2,1,2)
x = 1:instLW.npts+2;
y = imag(squeeze(igmLW(:, FOV, iobs)));
plot(x, y, x, bmin, x, bmax);
title(sprintf('Interferogram imag components, FOV %d FOR %d', FOV, FOR))
xlabel('index')
ylabel('count')
grid on; zoom on

