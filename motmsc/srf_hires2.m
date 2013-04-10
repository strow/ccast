
% look at the "edge SRFs", the SRFs for chan 1-4 at the low end of
% the band, for FOVs 1, 2, and 5.

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

cond(S1), cond(S2), cond(S3), cond(S4), cond(S5), cond(S6)

vg = s(1).vobs;

figure(1); clf
plot(vg, S1(:,1:4))
title('SW FOV 1, first 4 SRFs')
legend('chan 1', 'chan 2', 'chan 3', 'chan 4')
grid on; zoom on
saveas(gcf, 'SW_FOV_1_SRFs', 'fig')

figure(2); clf
plot(vg, S2(:,1:4))
title('SW FOV 2, first 4 SRFs')
legend('chan 1', 'chan 2', 'chan 3', 'chan 4')
grid on; zoom on
saveas(gcf, 'SW_FOV_2_SRFs', 'fig')

figure(3); clf
plot(vg, S5(:,1:4))
title('SW FOV 5, first 4 SRFs')
legend('chan 1', 'chan 2', 'chan 3', 'chan 4')
grid on; zoom on
saveas(gcf, 'SW_FOV_5_SRFs', 'fig')



