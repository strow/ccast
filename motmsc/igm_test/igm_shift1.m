%
% igm_shift1 -- check interferograms before and after extension
%

addpath ../source
addpath /home/motteler/matlab/export_fig

rpath = '/asl/data/cris/ccast/rdr60_hr/2015/306/';
gran1 = 'RDR_d20151102_t1539244.mat';
gran2 = 'RDR_d20151102_t1619242.mat';

sdir = 0;

load(fullfile(rpath, gran1))
iL = d1.sweep_dir.LWIT(5,:) == sdir;
iM = d1.sweep_dir.MWIT(5,:) == sdir;
iS = d1.sweep_dir.MWIT(5,:) == sdir;
LW1 = squeeze(d1.idata.LWIT(:,5,iL)) + 1i * squeeze(d1.qdata.LWIT(:,5,iL));
MW1 = squeeze(d1.idata.MWIT(:,5,iM)) + 1i * squeeze(d1.qdata.MWIT(:,5,iM));
SW1 = squeeze(d1.idata.SWIT(:,5,iS)) + 1i * squeeze(d1.qdata.SWIT(:,5,iS));

load(fullfile(rpath, gran2))
iL = d1.sweep_dir.LWIT(5,:) == sdir;
iM = d1.sweep_dir.MWIT(5,:) == sdir;
iS = d1.sweep_dir.MWIT(5,:) == sdir;
LW2 = squeeze(d1.idata.LWIT(:,5,iL)) + 1i * squeeze(d1.qdata.LWIT(:,5,iL));
MW2 = squeeze(d1.idata.MWIT(:,5,iM)) + 1i * squeeze(d1.qdata.MWIT(:,5,iM));
SW2 = squeeze(d1.idata.SWIT(:,5,iS)) + 1i * squeeze(d1.qdata.SWIT(:,5,iS));

clear d1

LW1d0 = pcorr2(LW1); 
MW1d0 = pcorr2(MW1);
SW1d0 = pcorr2(SW1);
LW2d0 = pcorr2(LW2); 
MW2d0 = pcorr2(MW2);
SW2d0 = pcorr2(SW2);

sdir = 1;

load(fullfile(rpath, gran1))
iL = d1.sweep_dir.LWIT(5,:) == sdir;
iM = d1.sweep_dir.MWIT(5,:) == sdir;
iS = d1.sweep_dir.MWIT(5,:) == sdir;
LW1 = squeeze(d1.idata.LWIT(:,5,iL)) + 1i * squeeze(d1.qdata.LWIT(:,5,iL));
MW1 = squeeze(d1.idata.MWIT(:,5,iM)) + 1i * squeeze(d1.qdata.MWIT(:,5,iM));
SW1 = squeeze(d1.idata.SWIT(:,5,iS)) + 1i * squeeze(d1.qdata.SWIT(:,5,iS));

load(fullfile(rpath, gran2))
iL = d1.sweep_dir.LWIT(5,:) == sdir;
iM = d1.sweep_dir.MWIT(5,:) == sdir;
iS = d1.sweep_dir.MWIT(5,:) == sdir;
LW2 = squeeze(d1.idata.LWIT(:,5,iL)) + 1i * squeeze(d1.qdata.LWIT(:,5,iL));
MW2 = squeeze(d1.idata.MWIT(:,5,iM)) + 1i * squeeze(d1.qdata.MWIT(:,5,iM));
SW2 = squeeze(d1.idata.SWIT(:,5,iS)) + 1i * squeeze(d1.qdata.SWIT(:,5,iS));

clear d1

LW1d1 = pcorr2(LW1); 
MW1d1 = pcorr2(MW1);
SW1d1 = pcorr2(SW1);
LW2d1 = pcorr2(LW2); 
MW2d1 = pcorr2(MW2);
SW2d1 = pcorr2(SW2);

whos LW1d0 MW1d0 SW1d0 LW2d0

figure(1); clf
n = 866;
x1 = n / 2; x2 = x1 + 1; y1 = 4.7e4;
plot(1:n, LW1d0, 1:n, LW1d1, x1, y1, 'r+', x2, y1, 'r+')
ax(1)=428; ax(2)=440; ax(3)=0; ax(4)=5e4; axis(ax);
title('120 LW old high res ITC interferograms, both sweeps')
xlabel('index'); ylabel('sensor raw')
text(x1, y1, '  n/2'); 
text(x2, y1, '  n/2 + 1'); 
grid on; zoom on 

figure(2); clf
n = 874;
x1 = n / 2; x2 = x1 + 1; y1 = 4.7e4;
plot(1:n, LW2d0, 1:n, LW2d1, x1, y1, 'r+', x2, y1, 'r+')
ax(1) = 432; ax(2) = 444; ax(3)=0; ax(4)=5e4; axis(ax)
title('120 LW extended ITC interferograms, both sweeps')
xlabel('index'); ylabel('sensor raw')
text(x1, y1, '  n/2'); 
text(x2, y1, '  n/2 + 1'); 
grid on; zoom on 
% saveas(gcf, 'igm_even_points', 'png')

figure(3); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
subplot(1,2,1)
n = 808;
x1 = n / 2; x2 = x1 + 1; y1 = 2300;
plot(1:n, SW2d0, 1:n, SW2d1, x1, y1, 'r+', x2, y1, 'r+')
ax(1)=400; ax(2)=410; ax(3)=0; ax(4)=2500; axis(ax)
title('120 SW extended ITC interferograms, both sweeps')
xlabel('index'); ylabel('sensor count')
text(x1, y1, '  n/2'); 
text(x2, y1, '  n/2 + 1'); 
grid on; zoom on 
% export_fig('igms_SW_new.pdf', '-m2', '-transparent')

% figure(4); clf
subplot(1,2,2)
n = 799;
x1 = n / 2; x2 = x1 + 1; y1 = 2000;
plot(1:n, SW1d0, 1:n, SW1d1, x1, y1, 'r+',  x2, y1, 'r+')
ax(1)=396; ax(2)=405; ax(3)=0; ax(4)=2100; axis(ax)
title('120 SW old high res ITC interferograms, both sweeps')
xlabel('index'); ylabel('sensor count')
text(x1, y1, '  n/2'); 
text(x2, y1, '  n/2 + 1'); 
grid on; zoom on 
% export_fig('igms_SW_old.pdf', '-m2', '-transparent')
  export_fig('igm_SW_centers.pdf', '-m2', '-transparent')

return

figure(5); clf
n = 1052;
x1 = n / 2; x2 = x1 + 1; y1 = 2e4;
plot(1:n, MW2d0, 1:n, MW2d1, x1, y1, 'r+', x2, y1, 'r+')
ax(1)=521; ax(2)=533; ax(3)=0; ax(4)=2.2e4; axis(ax)
title('120 MW old high res ITC interferograms, both sweeps')
xlabel('index'); ylabel('sensor count')
text(x1, y1, '  n/2'); 
text(x2, y1, '  n/2 + 1'); 
grid on; zoom on 

