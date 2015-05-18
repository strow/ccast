%
% sa_test3 -- plot stats for extended SA matrix
%

addpath /home/motteler/matlab/export_fig

% get periodic and regular SA matrices
load('../motmsc/SAfwd_HR2_SX_SW.mat'); 

band = inst.band;
npts = length(sfreq);

SAcond = zeros(1, 9);
rowsum = zeros(npts, 1);
colsum = zeros(npts, 1);

% loop on FOVs
for j = 1 : 9
  SAtmp = SAfwd(:, :, j);
  SAcond(j) = cond(SAtmp);
  colsum(:, j) = sum(SAtmp, 1);
  rowsum(:, j) = sum(SAtmp, 2);
end

% select a FOV
% iFOV = input('FOV > ');
iFOV = 1;

% condition number
fprintf(1, 'condition number %.3g\n', SAcond(iFOV))

%-------------------------------
% SA matrix row and column sums
%-------------------------------
figure(1); clf
subplot(2,1,1)
xind1 = 1 : npts;
xind2 = [sind(1), sind(end)];
plot(xind1, colsum(:, iFOV) - 1, 'b', xind2, [0 0], '+r')
ax = axis; ax(3) = -0.01; ax(4) = 0.01; axis(ax)
title(sprintf('%s FOV %d col diffs from 1', band, iFOV))
ylabel('sum')
grid on; zoom on

subplot(2,1,2)
plot(xind1, rowsum(:, iFOV) - 1, 'b', xind2, [0 0], '+r')
ax = axis; ax(3) = -0.01; ax(4) = 0.01; axis(ax)
title(sprintf('%s FOV %d row diffs from 1', band, iFOV))
xlabel('channel index')
ylabel('sum')
grid on; zoom on

% export_fig('ILS_sums.pdf', '-m2', '-transparent')

