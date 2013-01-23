
% compare bcast and ccast spectra

% dt11 is resample_mode = 1, calmode = 1
% dt12 is resample_mode = 1, calmode = 2
% dt22 is resample_mode = 1, calmode = 2

% sfile1 =   '../../data/2012/136/SDR_d20120515_t0646250.mat';
% sfile2 = '../../data/2012dt11/136/SDR_d20120515_t0646250.mat';

sfile1 =   '../../data/2012/136/SDR_d20120515_t0022272.mat';
sfile2 = '../../data/2012dt12/136/SDR_d20120515_t0022272.mat';

load(sfile1)
r1  = rSW;
vg1 = vSW;

load(sfile2)
r2  = rSW;
vg2 = vSW;

% rid for plot name
rtmp = rid;
rtmp(10) = ' ';

% get max common frequency grid
n1 = length(vg1);
n2 = length(vg2);
% v1 = max(vg1(1), vg2(1));
% v2 = min(vg1(n1), vg2(n2));
% dv = vg1(2) - vg1(1);
% vg = v1:dv:v2;

% get official user grid
wlaser = 773.1301;
[inst, user] = inst_params('SW', wlaser);
vg = user.v1 : user.dv : user.v2;

% get indices into common grid
ix1 = interp1(vg1, 1:n1, vg, 'nearest');
ix2 = interp1(vg2, 1:n2, vg, 'nearest');

% compare selected FOV, FOR, and scan
ifov = 1;
ifor = 15;
iscan = 31;

xx1 = real(rad2bt(vg, r1(ix1, ifov, ifor, iscan)));
xx2 = real(rad2bt(vg, r2(ix2, ifov, ifor, iscan)));

figure(1)

subplot(2,1,1)
plot(vg, xx1, vg, xx2)
title(sprintf('bcast vs ccast %s FOV %d FOR %d Scan %d', ...
               rtmp, ifov, ifor, iscan))
xlabel('channel freq, 1/cm')
ylabel('BT, K')
legend('bcast', 'ccast')

subplot(2,1,2)
plot(vg, xx1 - xx2)
xlabel('channel freq, 1/cm')
ylabel('BT, K')
legend('bcast - ccast')

return  % **** temporary end point ****

% choose FOR and scan, convert to Btemps
xx1 = real(rad2bt(vg, r1(ix1, :, 15, 51)));
xx2 = real(rad2bt(vg, r2(ix2, :, 15, 51)));

fovnames = {'FOV 1','FOV 2','FOV 3',...
            'FOV 4','FOV 5','FOV 6',...
            'FOV 7','FOV 8','FOV 9'};

plot(vg, xx1 - xx2)
legend(fovnames, 'location', 'best')

title(['band 1, ', rtmp])
xlabel('channel freq, 1/cm')
ylabel('BT, K')
grid
zoom on

% saveas(gcf, ['SW_',rid], 'fig')

