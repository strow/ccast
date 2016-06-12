%
% resampling tests, run from inside ccast calmain FOV loop
%

[t3x, frqx] = finterp(t3, inst.freq, user.dv);

[R0, frqy] = resamp(inst, user, 0);
[R1, frqy] = resamp(inst, user, 1);
[R2, frqy] = resamp(inst, user, 2);
[R3, frqy] = resamp(inst, user, 3);

t3y0 = R0 * t3;
t3y1 = R1 * t3;
t3y2 = R2 * t3;
t3y3 = R3 * t3;

btx  = rad2bt(frqx, t3x(:, 15));
bty0 = rad2bt(frqy, t3y0(:, 15));
bty2 = rad2bt(frqy, t3y2(:, 15));
bty3 = rad2bt(frqy, t3y3(:, 15));

% pv1 = floor(user.v1 / 10) * 10;
% pv2 = ceil(user.v2 / 10) * 10;

pv1 = round(inst.freq(1) / 10) * 10;
pv2 = round(inst.freq(end) / 10) * 10;

figure(1)
subplot(2,1,1)
plot(frqx, bty0 - btx)
axis([pv1, pv2, -0.05, 0.05])
title('resamp minus finterp, ATBD stock')
ylabel('dBT, K')
grid on; zoom on

subplot(2,1,2)
plot(frqx, bty2 - btx)
axis([pv1, pv2, -0.05, 0.05])
title('resamp minus finterp, ATBD w/ NOAA mod')
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

figure(2)
subplot(2,1,1)
plot(frqx, bty2 - btx)
axis([pv1, pv2, -0.05, 0.05])
title('resamp minus finterp, small N')
ylabel('dBT, K')
grid on; zoom on

subplot(2,1,2)
plot(frqx, bty3 - btx)
axis([pv1, pv2, -0.05, 0.05])
title('resamp minus finterp, big N')
xlabel('wavenumber')
ylabel('dBT, K')
grid on; zoom on

saveas(gcf, 'SW_resamp', 'png')

