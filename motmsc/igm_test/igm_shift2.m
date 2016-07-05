%
% igm_shift2 -- shift extended igms to pre-extended grid
%

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

LW1 = pcorr2(LW1); LW1 = mean(LW1, 2);
MW1 = pcorr2(MW1); MW1 = mean(MW1, 2);
SW1 = pcorr2(SW1); SW1 = mean(SW1, 2);
LW2 = pcorr2(LW2); LW2 = mean(LW2, 2);
MW2 = pcorr2(MW2); MW2 = mean(MW2, 2);
SW2 = pcorr2(SW2); SW2 = mean(SW2, 2);

whos LW1 MW1 SW1 LW2 MW2 SW2

figure(1); clf
plot(1:866, LW1, 1:866, LW2((1:866) + 4))
ax = axis; ax(1) = 428; ax(2) = 440; axis(ax)
title('ITC original and extended truncated shifted IGMs')
legend('original', 'extended')
xlabel('index'); 
ylabel('sensor')
grid on; zoom on 

figure(2); clf
plot(1:799, SW1, 1:799, SW2((1:799) + 5))
ax = axis; ax(1) = 395; ax(2) = 405; axis(ax)
title('ITC original and extended truncated shifted IGMs')
legend('original', 'extended')
xlabel('index'); 
ylabel('sensor')
grid on; zoom on 

figure(3); clf
plot(SW2((1:800) + 4))
ax = axis; ax(1) = 396; ax(2) = 406; axis(ax)
title('ITC extended IGM truncated to 800 pts and shifted')
xlabel('index'); 
ylabel('sensor')
grid on; zoom on 
