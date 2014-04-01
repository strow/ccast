
ifov = 1;

bc = load('cmp_loop1');
dt = load('cmp_loop1_dt');

ybc = mean(squeeze(bc.bt1(:, ifov, :)));
ydt = mean(squeeze(dt.bt1(:, ifov, :)));
y2  = mean(squeeze(bc.bt2(:, ifov, :)));

sv1 = bc.vrad(1);
sv2 = bc.vrad(end);
tgrid = (bc.rtime - bc.rtime(1)) ./ (60 * 60 * 1e6);

figure(1); clf
plot(tgrid, ybc - y2)
title(sprintf('FOV %d bcast - IDPS mean BT, %g to %g 1/cm', ifov, sv1, sv2))
xlabel('hours')
ylabel('dBT, K')
grid on; zoom on

figure(2); clf
plot(tgrid, ydt - y2)
title(sprintf('FOV %d davet - IDPS mean BT, %g to %g 1/cm', ifov, sv1, sv2))
xlabel('hours')
ylabel('dBT, K')
grid on; zoom on

figure(3); clf
plot(tgrid, ybc - ydt)
title(sprintf('FOV %d bcast - davet mean BT, %g to %g 1/cm', ifov, sv1, sv2))
xlabel('hours')
ylabel('dBT, K')
grid on; zoom on

