%
% hot_plots1 -- complex residual stds with shot noise fits
%

% get the data
d0 = load('imag_hot290.mat');
d1 = load('imag_hot300.mat');
d2 = load('imag_hot310.mat');
d3 = load('imag_hot320.mat');

% mean brightness temp by temp band
b0 = d0.bmSW;
b1 = d1.bmSW;
b2 = d2.bmSW;
b3 = d3.bmSW;

% complex residual std by temp band
c0 = d0.csSW;
c1 = d1.csSW;
c2 = d2.csSW;
c3 = d3.csSW;

% mean radiance by temperature band
vSW = d0.vSW;
r0 = bt2rad(vSW, b0);
r1 = bt2rad(vSW, b1);
r2 = bt2rad(vSW, b2);
r3 = bt2rad(vSW, b3);

% mean ccast nedn
nedn = d0.nmSW;

%----------------------------
% try fitting for a vector w
%----------------------------

w0 = (c0.^2 - nedn.^2) ./ r0;
w1 = (c1.^2 - nedn.^2) ./ r1;
w2 = (c2.^2 - nedn.^2) ./ r2;
w3 = (c3.^2 - nedn.^2) ./ r3;

w = (w0 + w1 + w2 + w3) / 4;

f0 = sqrt(nedn.^2 + w.*r0);
f1 = sqrt(nedn.^2 + w.*r1);
f2 = sqrt(nedn.^2 + w.*r2);
f3 = sqrt(nedn.^2 + w.*r3);
f280 = sqrt(nedn.^2 + w.*bt2rad(vSW, 280));

j = 5;
figure(1); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(2,1,1)
plot(vSW, nedn(:,j), vSW, c3(:,j), vSW, f3(:,j), vSW, f280(:,j))
axis([2150, 2550, 0.004, 0.02])
title(sprintf('FOV %d 320-330K shot noise fit', j))
legend('NEdN', 'imag std', 'shot noise fit', 'fit at 280K', ...
       'location', 'northwest')
ylabel('radiance')
grid on

subplot(2,1,2)
plot(vSW, nedn(:,j), vSW, c2(:,j), vSW, f2(:,j), vSW, f280(:,j)) 
axis([2150, 2550, 0.004, 0.02])
title(sprintf('FOV %d 310-320K shot noise fit', j))
legend('NEdN', 'imag std', 'shot noise fit', 'fit at 280K', ...
       'location', 'northwest')
ylabel('radiance')
grid on
% saveas(gcf, 'FOV_5_shot_fit_1', 'png')

figure(2); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(2,1,1)
plot(vSW, nedn(:,j), vSW, c1(:,j), vSW, f1(:,j), vSW, f280(:,j))
axis([2150, 2550, 0.004, 0.02])
title(sprintf('FOV %d 300-310K shot noise fit', j))
legend('NEdN', 'imag std', 'shot noise fit', 'fit at 280K', ...
       'location', 'northwest')
ylabel('radiance')
grid on

subplot(2,1,2)
plot(vSW, nedn(:,j), vSW, c0(:,j), vSW, f0(:,j), vSW, f280(:,j))
axis([2150, 2550, 0.004, 0.02])
title(sprintf('FOV %d 290-300K shot noise fit', j))
legend('NEdN', 'imag std', 'shot noise fit', 'fit at 280K', ...
       'location', 'northwest')
ylabel('radiance')
grid on
% saveas(gcf, 'FOV_5_shot_fit_2', 'png')

return

figure(3); clf
fname = fovnames;
plot(vSW, w)
grid on
title('frequency dependent weights w')
legend(fname, 'location', 'eastoutside')
legend(fname, 'location', 'northeast')  
xlabel('wavenumber')
ylabel('weight')
% saveas(gcf, 'freq_dep_weights_w', 'png')

return

%----------------------------
% try fitting for a single w
%----------------------------
w = 0.00005;
f0 = sqrt(nedn.^2 + w *r0);
f1 = sqrt(nedn.^2 + w *r1);
f2 = sqrt(nedn.^2 + w *r2);
f3 = sqrt(nedn.^2 + w *r3);
f280 = sqrt(nedn.^2 + w * bt2rad(vSW, 280));

j = 3;
figure(1); clf
subplot(2,1,1)
plot(vSW, nedn(:,j), vSW, d3.csSW(:,j), vSW, f3(:,j), vSW, f280(:,j))
title(sprintf('FOV %d 320-330K shot noise fit', j))
legend('NEdN', 'imag std', 'shot noise fit', 'fit at 280K', ...
       'location', 'north')
ylabel('radiance')
grid on

subplot(2,1,2)
plot(vSW, nedn(:,j), vSW, d0.csSW(:,j), vSW, f0(:,j), vSW, f280(:,j))
title(sprintf('FOV %d 290-300K shot noise fit', j))
legend('NEdN', 'imag std', 'shot noise fit', 'fit at 280K', ...
       'location', 'north')
ylabel('radiance')
grid on

j = 3;
figure(1); clf
subplot(2,1,1)
plot(vSW, nedn(:,j), vSW, d3.csSW(:,j), vSW, f3(:,j))
title(sprintf('FOV %d 320-330K shot noise fit', j))
legend('NEdN', 'imag std', 'shot noise fit', 'location', 'north')
ylabel('radiance')
grid on

subplot(2,1,2)
plot(vSW, nedn(:,j), vSW, d2.csSW(:,j), vSW, f2(:,j))
title(sprintf('FOV %d 310-320K shot noise fit', j))
legend('NEdN', 'imag std', 'shot noise fit', 'location', 'north')
ylabel('radiance')
grid on

figure(2); clf
subplot(2,1,1)
plot(vSW, nedn(:,j), vSW, d1.csSW(:,j), vSW, f1(:,j))
title(sprintf('FOV %d 300-310K shot noise fit', j))
legend('NEdN', 'imag std', 'shot noise fit', 'location', 'north')
ylabel('radiance')
grid on

subplot(2,1,2)
plot(vSW, nedn(:,j), vSW, d0.csSW(:,j), vSW, f0(:,j))
title(sprintf('FOV %d 290-300K shot noise fit', j))
legend('NEdN', 'imag std', 'shot noise fit', 'location', 'north')
ylabel('radiance')
grid on

return

%-------------------------------
% Tb and radiance means by band
%-------------------------------
j = 3;
figure(1); clf
subplot(2,1,1)
plot(vSW, b0(:,j), vSW, b1(:,j), vSW, b2(:,j),vSW, b3(:,j))
title(sprintf('FOV %d temperature band mean brightness temps', j))
legend('290-300K', '300-310K', '310-320K', '320-330K', ...
       'location', 'southeast')
ylabel('Tb, K')
grid on

subplot(2,1,2)
plot(vSW, r0(:,j), vSW, r1(:,j), vSW, r2(:,j), vSW, r3(:,j)) 
title(sprintf('FOV %d temperature band mean radiance', j))
legend('290-300K', '300-310K', '310-320K', '320-330K', 'location', 'north')
xlabel('wavenumber')
ylabel('radiance')
grid on

return

%-------------------------------------------
% complex residuals by Tb band for all FOVs
%--------------------------------------------
figure(1); clf
subplot(2,1,1)
plot(d0.vSW, d0.csSW)
axis([2150, 2550, 0, 0.04])
title('300-310K complex residual std')
legend(fname, 'location', 'eastoutside')
ylabel('radiance')
grid on; zoom on

subplot(2,1,2)
plot(d1.vSW, d1.csSW)
axis([2150, 2550, 0, 0.04])
title('300-310K complex residual std')
legend(fname, 'location', 'eastoutside')
ylabel('radiance')
grid on; zoom on

figure(2); clf
subplot(2,1,1)
plot(d2.vSW, d2.csSW)
axis([2150, 2550, 0, 0.04])
title('310-320K complex residual std')
legend(fname, 'location', 'eastoutside')
xlabel('wavenumber')
ylabel('radiance')
grid on; zoom on

subplot(2,1,2)
plot(d3.vSW, d3.csSW)
axis([2150, 2550, 0, 0.04])
title('320-330K complex residual std')
legend(fname, 'location', 'eastoutside')
xlabel('wavenumber')
ylabel('radiance')
grid on; zoom on

figure(3); clf
j = 5;
subplot(2,1,1)
plot(d0.vSW, d0.csSW(:,j), d1.vSW, d1.csSW(:,j), ...
     d2.vSW, d2.csSW(:,j), d3.vSW, d3.csSW(:,j), ...
     d1.vSW, d1.nmSW(:,j))
axis([2150, 2550, 0, 0.04])
title(sprintf('FOV %d complex residual std Tb bands', j))
legend('290-300K', '300-310K', '310-320K', '320-330K', ...
       'mean NEdN', 'location', 'north')
ylabel('radiance')
grid on; zoom on

j = 3;
subplot(2,1,2)
plot(d0.vSW, d0.csSW(:,j), d1.vSW, d1.csSW(:,j), ...
     d2.vSW, d2.csSW(:,j), d3.vSW, d3.csSW(:,j), ...
     d1.vSW, d1.nmSW(:,j))
axis([2150, 2550, 0, 0.04])
title(sprintf('FOV %d complex residual std Tb bands', j))
legend('290-300K', '300-310K', '310-320K', '320-330K', ...
       'mean NEdN', 'location', 'north')
xlabel('wavenumber')
ylabel('radiance')
grid on; zoom on

