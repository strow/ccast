
addpath ../source

rpath = '/asl/data/cris/ccast/rdr60_hr/2015/306/';
gran1 = 'RDR_d20151102_t1539244.mat';
gran2 = 'RDR_d20151102_t1619242.mat';

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

LW1 = pcorr2(LW1); 
MW1 = pcorr2(MW1);
SW1 = pcorr2(SW1);
LW2 = pcorr2(LW2); 
MW2 = pcorr2(MW2);
SW2 = pcorr2(SW2);

whos LW1 MW1 SW1 LW2 MW2 SW2

figure(1); clf
plot(1:866, LW1, 433, 4e4, 'o',  434, 4e4, 'o')
ax = axis; ax(1) = 428; ax(2) = 440; axis(ax)
title('60 LW standard ITC interferograms')
xlabel('index'); ylabel('sensor count')
grid on; zoom on 

figure(2); clf
plot(1:874, LW2, 437, 4e4, 'o',  438, 4e4, 'o')
ax = axis; ax(1) = 432; ax(2) = 444; axis(ax)
title('60 LW extended ITC interferograms')
xlabel('index'); ylabel('sensor count')
grid on; zoom on 

figure(3); clf
plot(1:799, SW1, 399, 1500, 'o',  400, 1500, 'o')
ax = axis; ax(1) = 395; ax(2) = 405; axis(ax)
title('60 SW standard ITC interferograms')
xlabel('index'); ylabel('sensor count')
grid on; zoom on 

figure(4); clf
plot(1:808, SW2, 404, 1500, 'o', 405, 1500, 'o')
ax = axis; ax(1) = 400; ax(2) = 410; axis(ax)
title('60 SW extended ITC interferograms')
xlabel('index'); ylabel('sensor count')
grid on; zoom on 

