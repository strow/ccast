%
% sa_test2 -- plot difference of SA inv row and col sums from 1
%

addpath /home/motteler/matlab/export_fig

% get periodic and regular SA matrices
d1 = load('../inst_data/SAinv_HR2_Pn_SW.mat');
d2 = load('../inst_data/SAinv_HR2_SX_SW.mat'); 

% select a FOV
iFOV = 2;
SAp = d1.SAinv(:,:,iFOV);
SAr = d2.SAinv(:,:,iFOV);
[m,n] = size(SAr);

% show condition numbers
cond(SAp)
cond(SAr)

%-------------------------------
% SA matrix row and column sums
%-------------------------------
figure(1); clf
subplot(2,1,1)
plot(1:n, sum(SAr,1)-1, 'g', 1:n, sum(SAr,2)-1, 'r')
ax = axis; ax(3) = -0.2; ax(4) = 0.2; axis(ax)
title(sprintf('SW FOV %d regular sinc inv column and row diffs from 1', iFOV))
legend('col sums', 'row sums', 'location', 'north')
ylabel('sum')
grid on; zoom on

subplot(2,1,2)
plot(1:n, sum(SAp,1)-1, 'g', 1:n, sum(SAp,2)-1, 'r')
ax = axis; ax(3) = -0.2; ax(4) = 0.2; axis(ax)
title(sprintf('SW FOV %d periodic sinc inv column and row diffs from 1', iFOV))
legend('col sums', 'row sums', 'location', 'north')
xlabel('channel index')
ylabel('sum')
grid on; zoom on
% export_fig('ILS_sums.pdf', '-m2', '-transparent')

