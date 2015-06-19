
load ../inst_data/SAinv_LR_Pn_ag_LW.mat

SA1 = inv(SAinv(:,:,1));
SA2 = inv(SAinv(:,:,2));
SA5 = inv(SAinv(:,:,5));

rimp = zeros(866, 1);
rimp(1:100:866) = 1;

[r0, v0] = finterp2(rimp, inst.freq, 24);
[r1, v1] = finterp2(SA1 * rimp, inst.freq, 24);
[r2, v2] = finterp2(SA2 * rimp, inst.freq, 24);
[r5, v5] = finterp2(SA5 * rimp, inst.freq, 24);

figure(1); clf
% plot(v0, r0, v1 + 0.32, r1)
% plot(v0, r0, v2 + 0.16, r2)
plot(v0, r0, v5 + 0.02, r5)
% axis([789.5, 790, 0.95, 1.01])
axis([851.7, 852.2, 0.95, 1.01])
legend('impulse', 'shifted')
grid on; zoom on

