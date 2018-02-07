%
% find a2 values to minimize residuals vs a reference spec
%

addpath ../motmsc/utils

tdir = 'atbd_set_3';

% list of test runs
tlist = {
  'atbd_m20.mat'
  'atbd_m15.mat'
  'atbd_m10.mat'
  'atbd_m05.mat'
  'atbd_ref.mat'
  'atbd_p05.mat'
  'atbd_p10.mat'
  'atbd_p15.mat'
  'atbd_p20.mat'
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
  ixLW =  700 <= vLW & vLW <= 1000;
% ixLW =  700 <= vLW & vLW <= 800;
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

% new UMBC ATBD values
a2LW = [
    0.0138
    0.0188
    0.0171
    0.0154
    0.0403
    0.0114
    0.0096
    0.0184
    0.0074
];
a2MW = [0 0 0 0 0 0 0 0 0.21]';

a2tmpLW = a2LW .* wlist(iminLW);
a2tmpMW = a2MW .* wlist(iminMW);

% old value btab at iref
boldLW = btabLW(:,:,iref);
boldMW = btabMW(:,:,iref);

% save(fullfile(tdir, 'a2vals'), 'a2tmpLW', 'a2tmpMW');

% ---- plot ATBD a2 weights ----
figure(1); clf
subplot(2,1,1)
bar([a2LW, a2tmpLW])
axis([0, 10, 0, 0.05])
title('current and test LW UMBC ATBD weights')
legend('current', 'test', 'location', 'northwest')
% xlabel('FOV')
ylabel('a2 weight, 1/V')
grid on; zoom on

subplot(2,1,2)
bar([a2MW, a2tmpMW])
% axis([0, 10, 0, 0.045])
title('current and test MW UMBC ATBD weights')
legend('current', 'test', 'location', 'northwest')
xlabel('FOV')
ylabel('a2 weight, 1/V')
grid on; zoom on

% --- LW current and test comparison
figure(2); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
s = 0.2; % y-axis scale
subplot(2,1,1)
plot(vLW, boldLW - brefLW)
axis([650, 1100, -s, s])
title('all FOVs minus reference, LW UMBC ATBD current')
legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
% xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on

subplot(2,1,2)
plot(vLW, bminLW - brefLW)
axis([650, 1100, -s, s])
title('all FOVs minus reference, LW UMBC ATBD test')
legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on

% --- MW current and test comparison
figure(3); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
s = 0.2; % y-axis scale
subplot(2,1,1)
plot(vMW, boldMW - brefMW)
axis([1200, 1760, -s, s])
title('all FOVs minus reference, MW UMBC ATBD current')
  legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
% xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on

subplot(2,1,2)
plot(vMW, bminMW - brefMW)
axis([1200, 1760, -s, s])
title('all FOVs minus reference, MW UMBC ATBD test')
  legend(fovnames, 'location', 'south', 'orientation', 'horizontal')
xlabel('wavenumber')
ylabel('dTb, K')
grid on; zoom on


