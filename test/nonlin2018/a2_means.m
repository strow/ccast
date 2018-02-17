%
% a2_means - tabulate and plot a2 means from several fitting runs
%

d1 = load('a2v4_set_1/a2vals');
d2 = load('a2v4_set_2/a2vals');
d3 = load('a2v4_set_3/a2vals');
d4 = load('a2v4_set_4/a2vals');
d5 = load('a2v4_set_5/a2vals');

a2tabLW = [d1.a2tmpLW, d2.a2tmpLW, d3.a2tmpLW, d4.a2tmpLW, d5.a2tmpLW];
a2tabMW = [d1.a2tmpMW, d2.a2tmpMW, d3.a2tmpMW, d4.a2tmpMW, d5.a2tmpMW];
a2newLW = mean(a2tabLW, 2);
a2newMW = mean(a2tabMW, 2);

% UW a2v4 values
a2v4tmp = [
   0.0119     0       0
   0.0157     0       0
   0.0152     0       0
   0.0128     0       0
   0.0268     0       0
   0.0110     0       0
   0.0091     0       0
   0.0154     0       0
   0.0079     0.0811  0
];
a2v4LW = a2v4tmp(:, 1);
a2v4MW = a2v4tmp(:, 2);

% ---- plot a2v4 and new weights ----
figure(1); clf
subplot(2,1,1)
bar([a2v4LW, a2newLW])
axis([0, 10, 0, 0.04])
title('LW a2v4 and mean adjusted weights')
legend('current', 'test', 'location', 'northwest')
% xlabel('FOV')
ylabel('a2 weight, 1/V')
grid on; zoom on

subplot(2,1,2)
bar([a2v4MW, a2newMW])
axis([0, 10, 0, 0.1])
title('MW a2v4 and mean adjusted weights')
legend('current', 'test', 'location', 'northwest')
xlabel('FOV')
ylabel('a2 weight, 1/V')
grid on; zoom on

