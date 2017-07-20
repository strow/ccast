%
% plot_tbinY - show combined results from airs_tbin and cris_tbin
%

d1 = load('airs_tbinW');
d3 = load('airs_tbinX');
d5 = load('airs_tbinY');
d7 = load('airs_tbinZ');

d2 = load('cris_tbinW');
d4 = load('cris_tbinX');
d6 = load('cris_tbinY');
d8 = load('cris_tbinZ');

d1.tbin = d1.tbin + d3.tbin + d5.tbin + d7.tbin;
d2.tbin = d2.tbin + d4.tbin + d6.tbin + d8.tbin;

na = sum(d1.tbin)
nc = sum(d2.tbin)
tind = d1.tind;

figure(1)
subplot(2,1,1)
  plot(tind, d1.tbin, tind, (na/nc)*d2.tbin, 'linewidth', 2)
% plot(tind, d1.tbin, tind, d2.tbin, 'linewidth', 2)
  axis([200, 330, 0, 8e6])
% axis([200, 305, 0, 4e5])
  title('obs count by 900 cm-1 temperature bins')
% title('obs count by SW cm-1 temperature bins')
legend('AIRS', 'CrIS', 'location', 'northwest')
grid on

subplot(2,1,2)
  plot(tind, ((na/nc)* d2.tbin - d1.tbin) ./ d1.tbin, 'linewidth', 2)
% plot(tind, (d2.tbin - d1.tbin) ./ d1.tbin, 'linewidth', 2)
  axis([200, 330,-0.1, 0.2])
% axis([200, 305 -0.1, 0.4])
title('CrIS minus AIRS relative difference')
xlabel('Tb, K')
grid on

return

figure(2)
subplot(2,1,1)
plot(tind, d1.tbin, tind, (na/nc)* d2.tbin, 'linewidth', 2)
% axis([285, 305, 0, 4e5])
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



