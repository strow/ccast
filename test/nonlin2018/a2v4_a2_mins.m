%
% find a2 values to minimize residuals vs a reference spec
%

addpath ../motmsc/utils

tdir = 'a2v4_set_2';

% list of test runs
tlist = {
  'a2v4_m20.mat'
  'a2v4_m15.mat'
  'a2v4_m10.mat'
  'a2v4_m05.mat'
  'a2v4_ref.mat'
  'a2v4_p05.mat'
  'a2v4_p10.mat'
  'a2v4_p15.mat'
  'a2v4_p20.mat'
};
nrun = length(tlist);

% a2 weights from the above
wlist = (0.80 : 0.05 : 1.20)';

% index of ref (0 offset) run
iref = 5; 

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

% reference value
k = iref;
  brefLW = (btabLW(:,6,k) + btabLW(:,7,k) + btabLW(:,9,k)) / 3;
% brefLW = (btabLW(:,7,k) + btabLW(:,9,k)) / 2;
% brefLW = btabLW(:,7,k);

brefMW = sum(btabMW(:,1:8,k),2) / 8;

% frequency fit interval
% ixLW =  690 <= vLW & vLW <= 730;
  ixLW =  700 <= vLW & vLW <= 1000;
  ixMW = 1250 <= vMW & vMW <= 1700;

% search setup
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

% sanity check
% bxx = zeros(717, 9);
% for j = 1 : 9
%   for i = 1 : 9
%     bxx(:,j) = btabLW(:,j,iminLW(j));
%   end
% end
% isequal(bxx, bminLW)

% use the UW a2v4 values
a2tmp = [
   0.0119     0       0
   0.0157     0       0
   0.0152     0       0
   0.0128     0       0
   0.0268     0       0
   0.0110     0       0
   0.0091     0       0
   0.0154     0       0
   0.0079     0.0811  0
];
a2LW = a2tmp(:, 1);
a2MW = a2tmp(:, 2);
a2tmpLW = a2tmp(:, 1) .* wlist(iminLW);
a2tmpMW = a2tmp(:, 2) .* wlist(iminMW);

% old value btab at iref
boldLW = btabLW(:,:,iref);
boldMW = btabMW(:,:,iref);

save(fullfile(tdir, 'a2vals'), 'a2tmpLW', 'a2tmpMW');

% ---- plot a2v4 and new weights ----
figure(1); clf
subplot(2,1,1)
bar([a2LW, a2tmpLW])
axis([0, 10, 0, 0.05])
title('current and test LW UW NPP a2v4 weights')
legend('current', 'test', 'location', 'northwest')
% xlabel('FOV')
ylabel('a2 weight, 1/V')
grid on; zoom on

subplot(2,1,2)
bar([a2MW, a2tmpMW])
% axis([0, 10, 0, 0.045])
title('current and test MW UW NPP a2v4 weights')
legend('current', 'test', 'location', 'northwest')
xlabel('FOV')
ylabel('a2 weight, 1/V')
grid on; zoom on

% --- LW current and test comparison
figure(2); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
s = 0.2; % y-axis scale
subplot(2,1,1)
plot(vLW, boldLW - brefLW)
axis([650, 1100, -s, s])
title('all FOVs minus reference, LW UW NPP a2v4 current')
legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
% xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on

subplot(2,1,2)
plot(vLW, bminLW - brefLW)
axis([650, 1100, -s, s])
title('all FOVs minus reference, LW UW NPP a2v4 test')
legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on

% --- MW current and test comparison
figure(3); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
s = 0.2; % y-axis scale
subplot(2,1,1)
plot(vMW, boldMW - brefMW)
axis([1200, 1760, -s, s])
title('all FOVs minus reference, MW UW NPP a2v4 current')
  legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
% xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on

subplot(2,1,2)
plot(vMW, bminMW - brefMW)
axis([1200, 1760, -s, s])
title('all FOVs minus reference, MW UW NPP a2v4 test')
  legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on


