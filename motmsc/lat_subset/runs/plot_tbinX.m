%
% plot_tbin - show results from airs_tbin and cris_tbin
%
% *_tbin1, 2016 SW 29-day test
% *_tbin3, 2016 LW 29-day test
% *_tbin4, 2017 SW 36 day test
% *_tbin5, 2016 LW 32 day test w/ lat subsetting
% *_tbin6, 2016 LW 48 day test 1 w/ lat subsetting
% *_tbin7, 2016 LW 48 day test 2 w/ lat subsetting
%

d1 = load('cris_tbin6');
d2 = load('cris_tbin7');

na = sum(d1.tbin)
nc = sum(d2.tbin)
tind = d1.tind;

figure(1)
subplot(2,1,1)
plot(tind, d1.tbin, tind, (na/nc)*d2.tbin, 'linewidth', 2)
  axis([200, 330, 0, 5e5])
  title('obs count by 900 cm-1 temperature bins')
% title('obs count by SW cm-1 temperature bins')
legend('CrIS 1', 'CrIS 2')
grid on

subplot(2,1,2)
plot(tind, ((na/nc)* d2.tbin - d1.tbin) ./ d1.tbin, 'linewidth', 2)
axis([200, 330, -0.2, 0.2])
title('CrIS 1 minus CrIS 2 relative difference')
xlabel('Tb, K')
grid on

return

figure(2)
subplot(2,1,1)
plot(tind, d1.tbin, tind, (na/nc)* d2.tbin, 'linewidth', 2)
  axis([285, 305, 0, 4e5])
  title('obs count by 900 cm-1 temperature bins')
% title('obs count by SW temperature bins')
legend('AIRS', 'CrIS')
grid on

subplot(2,1,2)
plot(tind, ((na/nc)* d2.tbin - d1.tbin) ./ d1.tbin, 'linewidth', 2)
  axis([285, 305, -0.05, 0.1])
title('CrIS minus AIRS relative difference')
xlabel('Tb, K')
grid on

return

% d3 = load('cris_tbin1_oldQC');
% n3 = sum(d3.tbin);

figure(3)
subplot(2,1,1)
plot(tind, d1.tbin, tind, (na/nc)* d2.tbin, ...
                    tind, (na/n3)* d3.tbin, 'linewidth', 2)
title('obs count by SW temperature bin')
legend('AIRS', 'CrIS new QC', 'CrIS old QC')
grid on

subplot(2,1,2)
plot(tind, (d3.tbin - d2.tbin) ./ d2.tbin, 'linewidth', 2)
title('CrIS old QC minus new QC relative difference')
xlabel('Tb, K')
grid on

% [sum(d1.tbin), sum(d2.tbin)]
% [sum(d1.tbin(51:71)), sum(d2.tbin(51:71))]
% [sum(d1.tbin(51:71)) / sum(d1.tbin),  sum(d2.tbin(51:71)) / sum(d2.tbin)]



