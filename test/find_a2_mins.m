
addpath ../motmsc/utils

tdir = 'a2_set2_4';

% list of test runs
tlist = {
  'a2v3_m35.mat'
  'a2v3_m30.mat'
  'a2v3_m25.mat'
  'a2v3_m20.mat'
  'a2v3_m15.mat'
  'a2v3_m10.mat'
  'a2v3_m05.mat'
  'a2v3_ref.mat'
  'a2v3_p05.mat'
  'a2v3_p10.mat'
  'a2v3_p15.mat'
  'a2v3_p20.mat'
  'a2v3_p25.mat'
  'a2v3_p30.mat'
};
nrun = length(tlist);

% a2 weights from the above
wlist = 0.65 : 0.05 : 1.30;

% index of ref (0 offset) run
iref = 8; 

% build btab from a2 run means
for i = 1 : nrun
  d1 = load(fullfile(tdir, tlist{i}));
  if i == 1
    vLW = d1.vLW;
    vMW = d1.vMW;
    nchanLW = length(vLW);
    nchanMW = length(vMW);
    btabLW = NaN(nchanLW,9,nrun);
    btabMW = NaN(nchanMW,9,nrun);
  end
  btabLW(:,:,i) = d1.mLW;
  btabMW(:,:,i) = d1.mMW;
end

% target value
k = iref - 2;
  brefLW = (btabLW(:,6,k) + btabLW(:,7,k) + btabLW(:,9,k)) / 3;
% brefLW = (btabLW(:,7,k) + btabLW(:,9,k)) / 2;
% brefLW = btabLW(:,7,k);

brefMW = sum(btabMW(:,1:8,k),2) / 8;

% frequency fit interval
ixLW =  700 <= vLW & vLW <= 1000;
ixMW = 1250 <= vMW & vMW <= 1700;

% min search setup
rminLW = ones(9,1) * 1e6;
iminLW = NaN(9,1);
bminLW = NaN(nchanLW, 9);
rminMW = ones(9,1) * 1e6;
iminMW = NaN(9,1);
bminMW = NaN(nchanMW, 9);

% find mins
for j = 1 : 9
  for i = 1 : nrun
    tminLW = rms(btabLW(ixLW,j,i) - brefLW(ixLW));
    tminMW = rms(btabMW(ixMW,j,i) - brefMW(ixMW));
    if tminLW < rminLW(j)
      rminLW(j) = tminLW;
      iminLW(j) = i;
      bminLW(:,j) = btabLW(:,j,i);
    end
    if tminMW < rminMW(j)
      rminMW(j) = tminMW;
      iminMW(j) = i;
      bminMW(:,j) = btabMW(:,j,i);
    end
  end
end

% show min indices
iminLW'
iminMW'

% UW is btabLW at iref
bUWLW = btabLW(:,:,iref);
bUWMW = btabMW(:,:,iref);

% UW a2v3 values
a2tmp = [
  0.0153      0         0
  0.0175      0         0
  0.0167      0         0
  0.0154      0         0
  0.0336      0         0
  0.0110      0         0
  0.0094      0         0
  0.0204      0         0
  0.0095      0.0943    0
];

a2v3LW = a2tmp(:,1);
a2v3MW = a2tmp(:,2);

a2tmpLW = a2v3LW .* wlist(iminLW)';
a2tmpMW = a2v3MW .* wlist(iminMW)';

save(fullfile(tdir, 'a2vals'), 'a2tmpLW', 'a2tmpMW');

% --- plot LW diff from ref and a2 weights ---
figure(1); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
subplot(2,1,1)
plot(vLW, bminLW - brefLW)
axis([650, 1100, -0.15, 0.15])
title('all FOVs minus ref, UMBC a2 test')
% legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on

subplot(2,1,2)
bar([a2v3LW, a2tmpLW])
axis([0, 10, 0, 0.045])
title('current and test a2 weights')
legend('UW a2v3', 'UMBC test', 'location', 'northwest')
xlabel('FOV')
ylabel('a2 weight, 1/V')
grid on; zoom on
% saveas(gcf, sprintf('%s_fig_1', tdir), 'png')

return

% --- plot MW diff from ref and a2 weights ---
figure(2); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
subplot(2,1,1)
plot(vMW, bminMW - brefMW)
axis([1200, 1760, -0.2, 0.8])
title('all FOVs minus ref, UMBC a2 test')
% legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on

subplot(2,1,2)
bar([a2v3MW, a2tmpMW])
% axis([0, 10, 0, 0.045])
title('current and test a2 weights')
legend('UW a2v3', 'UMBC test', 'location', 'northwest')
xlabel('FOV')
ylabel('a2 weight, 1/V')
grid on; zoom on
% saveas(gcf, sprintf('%s_fig_2', tdir), 'png')

return

% --- LW UW and UMBC comparison
figure(3); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
s = 0.3; % y-axis scale
subplot(2,1,1)
plot(vLW, bminLW - brefLW)
axis([650, 1100, -s, s])
title('all FOVs minus ref, UMBC a2 test')
% legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on

subplot(2,1,2)
plot(vLW, bUWLW - brefLW)
axis([650, 1100, -s, s])
title('all FOVs minus ref, UW a2v3')
% legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on
% saveas(gcf, sprintf('%s_fig_3', tdir), 'png')

% --- MW UW and UMBC comparison
figure(4); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
s = 0.3; % y-axis scale
subplot(2,1,1)
plot(vMW, bminMW - brefMW)
axis([1200, 1760, -0.4, 1.0])
title('all FOVs minus ref, UMBC a2 test')
% legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on

subplot(2,1,2)
plot(vMW, bUWMW - brefMW)
axis([1200, 1760, -0.4, 1.0])
title('all FOVs minus ref, UW a2v3')
% legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
% xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on
% saveas(gcf, sprintf('%s_fig_4', tdir), 'png')

