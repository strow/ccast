%
% resampling tests, run from inside ccast calmain FOV loop
%

[t3x, frqx] = finterp(t3, inst.freq, user.dv);

[R3, frqy] = resamp(inst, user, 3);
[R4, frqy] = resamp(inst, user, 4);

t3y3 = R3 * t3;
t3y4 = R4 * t3;

iFOR = 12;
btx  = real(rad2bt(frqx, t3x(:, iFOR)));
bty3 = real(rad2bt(frqy, t3y3(:, iFOR)));
bty4 = real(rad2bt(frqy, t3y4(:, iFOR)));

pv1 = round(inst.freq(1) / 10) * 10;
pv2 = round(inst.freq(end) / 10) * 10;

figure(1)
subplot(2,1,1)
plot(frqx, bty3 - btx)
axis([pv1, pv2, -0.05, 0.05])
title('resamp minus finterp, big N')
ylabel('dBT, K')
grid on; zoom on

subplot(2,1,2)
plot(frqx, bty4 - btx)
axis([pv1, pv2, -0.05, 0.05])
title('resamp minus finterp, sinc basis')
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

saveas(gcf, [inst.band,'_rebase'], 'png')

