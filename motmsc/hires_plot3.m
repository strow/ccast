
% compare SRFs for FOVs 1, 2, and 5 at a mid-band channel
% interpolate the plots to a finer grid.

load ../inst_data/SRF_v33aHR_SW.mat

S1 = squeeze(s(1).stab(:,:,1));
S2 = squeeze(s(1).stab(:,:,2));
S3 = squeeze(s(1).stab(:,:,3));
S4 = squeeze(s(1).stab(:,:,4));
S5 = squeeze(s(1).stab(:,:,5));
S6 = squeeze(s(1).stab(:,:,6));
S7 = squeeze(s(1).stab(:,:,7));
S8 = squeeze(s(1).stab(:,:,8));
S9 = squeeze(s(1).stab(:,:,9));

[m,n] = size(S1);

% cond(S1), cond(S2), cond(S3), cond(S4), cond(S5), cond(S6)
% S1a = S1(1:n-1, 2:n);
% S2a = S2(1:n-1, 2:n);
% S5a = S5(1:n-1, 2:n);
% cond (S1a), cond(S2a), cond(S5a)

% pick a channel near the center
ci = 401; 

% channel frequency grid
vg = s(1).vobs;  
dv = vg(2) - vg(1);
[S1x, v1x] = finterp(S1(:,ci), vg, dv/20);
[S2x, v2x] = finterp(S2(:,ci), vg, dv/20);
[S5x, v5x] = finterp(S5(:,ci), vg, dv/20);

figure(1); clf
plot(v1x, S1x, 'b', v1x, S2x, 'g', v1x, S5x, 'r', ...
     vg, S1(:,ci), 'b+', vg, S2(:,ci), 'g+', vg, S5(:,ci), 'r+');
axis([2356, 2362, -0.24, 1.04])
title('corner, side, and center FOV SRF comparison')
legend('FOV 1', 'FOV 2', 'FOV 5', 'location', 'northeast')
grid on; zoom on
saveas(gcf, 'SW_FOV_125_SRFs', 'fig')

% figure(1); clf
% plot(v1x, S1x, v1x, S2x, v1x, S5x)
% title('corner, side, and center FOV comparison')
% legend('FOV 1', 'FOV 2', 'FOV 5')
% grid on; zoom on
% saveas(gcf, 'SW_FOV_1_SRFs_vx', 'fig')


