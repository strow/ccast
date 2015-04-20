%
% sa_test1 -- plot difference of SA row and column sums from 1
%

addpath /home/motteler/matlab/export_fig

% get periodic and regular SA matrices
d1 = load('../inst_data/SRF_v33a_HR2_Pn_SW.mat');
d2 = load('../inst_data/SRF_v33a_HR2_S_SW.mat'); 

% select a FOV
iFOV = 1;
SAp = d1.s(1).stab(:,:,iFOV);
SAr = d2.s(1).stab(:,:,iFOV);
[m,n] = size(SAr);

% trim test
% k = 100;
% ix = k : n-k+1;
% SAr = SAr(ix, ix);
% SAp = SAp(ix, ix);
% [m,n] = size(SAr);

% renormalization test
% SAr = SAr ./ (ones(n,1) * sum(SAr, 1));

% show condition numbers
cond(SAp)
cond(SAr)

% conditon for submatrix
k = 100;
ix = k : n-k+1;
cond(SAr(ix, ix))

%-------------------------------
% SA matrix row and column sums
%-------------------------------
figure(1); clf
subplot(2,1,1)
plot(1:n, sum(SAr,1)-1, 'g', 1:n, sum(SAr,2)-1, 'r')
ax = axis; ax(3) = -5e-3; ax(4) = 5e-3; axis(ax)
title(sprintf('SW FOV %d regular sinc column and row difference from 1', iFOV))
legend('col sums', 'row sums', 'location', 'north')
ylabel('sum')
grid on; zoom on

subplot(2,1,2)
plot(1:n, sum(SAp,1)-1, 'g', 1:n, sum(SAp,2)-1, 'r')
ax = axis; ax(3) = -5e-3; ax(4) = 5e-3; axis(ax)
title(sprintf('SW FOV %d periodic sinc column and row difference from 1', iFOV))
legend('col sums', 'row sums', 'location', 'north')
xlabel('channel index')
ylabel('sum')
grid on; zoom on
export_fig('ILS_sums.pdf', '-m2', '-transparent')

%-------------------------------------
% detail of first 4 SA matrix columns
%-------------------------------------
figure(2); clf
j = 4;   % number of ILS to plot
k = 8;   % number of points to plot
subplot(2,2,1)
plot(1:k, SAr(1:k, 1:j))
axis([1, k, -0.2, 0.8])
title('regular sinc first 4 ILS left')
legend('ILS 1', 'ILS 2', 'ILS 3', 'ILS 4', 'location', 'northeast')
subplot(2,2,2)
plot(n-k+1:n, SAr(n-k+1:n, 1:j))
axis([n-k+1, n, -0.2, 0.8])
title('regular sinc first 4 ILS right')
legend('ILS 1', 'ILS 2', 'ILS 3', 'ILS 4', 'location', 'northwest')

subplot(2,2,3)
plot(1:k, SAp(1:k, 1:j))
axis([1, k, -0.2, 0.8])
title('periodic sinc first 4 ILS left')
legend('ILS 1', 'ILS 2', 'ILS 3', 'ILS 4', 'location', 'northeast')
subplot(2,2,4)
plot(n-k+1:n, SAp(n-k+1:n, 1:j))
axis([n-k+1, n, -0.2, 0.8])
title('periodic sinc first 4 ILS right')
legend('ILS 1', 'ILS 2', 'ILS 3', 'ILS 4', 'location', 'northwest')
export_fig('ILS_wrap.pdf', '-m2', '-transparent')


