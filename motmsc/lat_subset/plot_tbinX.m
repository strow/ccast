%
% plot_tbinX - show combined results from airs_tbin and cris_tbin
%

d1 = load('airs_tbinW');
d3 = load('airs_tbinX');
d5 = load('airs_tbinY');
d7 = load('airs_tbinZ');

d2 = load('cris_tbinW');
d4 = load('cris_tbinX');
d6 = load('cris_tbinY');
d8 = load('cris_tbinZ');

tbin_a = d1.tbin + d3.tbin + d5.tbin + d7.tbin;
tbin_c = d2.tbin + d4.tbin + d6.tbin + d8.tbin;
tind = d1.tind;

% option to merge bins
if 0
  k =  floor(numel(d1.tbin)/2);
  tmp_a = zeros(k, 1);
  tmp_c = zeros(k, 1);
  ix = 1:k;
  tmp_a(ix) = tbin_a(2*ix-1) + tbin_a(2*ix);
  tmp_c(ix) = tbin_c(2*ix-1) + tbin_c(2*ix);
  tmp_t = tind(2*ix-1)'; 
  tbin_a = tmp_a;
  tbin_c = tmp_c;
  tind = tmp_t;
end

na = sum(tbin_a)
nc = sum(tbin_c)

figure(1)
subplot(2,1,1)
plot(tind, tbin_a, tind, (na/nc)*tbin_c, 'linewidth', 2)
axis([200, 305, 0, 6e6])
title('obs count by 900 cm-1 temperature bins')
legend('AIRS', 'CrIS', 'location', 'northwest')
grid on

subplot(2,1,2)
plot(tind, ((na/nc)* tbin_c - tbin_a) ./ tbin_a, 'linewidth', 2)
axis([200, 305 -0.1, 0.1])
title('CrIS minus AIRS relative difference')
xlabel('Tb, K')
grid on

return

figure(2)
subplot(2,1,1)
plot(tind, tbin_a, tind, (na/nc)* tbin_c, 'linewidth', 2)
axis([285, 305, 0, 4e5])
title('obs count by 900 cm-1 temperature bins')
legend('AIRS', 'CrIS')
grid on

subplot(2,1,2)
plot(tind, ((na/nc)* tbin_c - tbin_a) ./ tbin_a, 'linewidth', 2)
axis([285, 305, -0.05, 0.1])
title('CrIS minus AIRS relative difference')
xlabel('Tb, K')
grid on

