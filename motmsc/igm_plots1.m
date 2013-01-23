
load igm_min_max_054

figure(1); clf
[mask, bmax, bmin] = hires_bitmask('LW');
n = length(bmax);
plot(1:n, igm_maxLW, 1:n, bmax, 1:n, igm_minLW, 1:n, bmin) 
title('LW high res max, min, and mask')
xlabel('igm index')
ylabel('igm count')
grid on; zoom on
saveas(gcf, 'igm_min_max_LW', 'png')

figure(2); clf
[mask, bmax, bmin] = hires_bitmask('MW');
n = length(bmax);
plot(1:n, igm_maxMW, 1:n, bmax, 1:n, igm_minMW, 1:n, bmin) 
title('MW high res max, min, and mask')
xlabel('igm index')
ylabel('igm count')
grid on; zoom on
saveas(gcf, 'igm_min_max_MW', 'png')

figure(3); clf
[mask, bmax, bmin] = hires_bitmask('SW');
n = length(bmax);
plot(1:n, igm_maxSW, 1:n, bmax, 1:n, igm_minSW, 1:n, bmin) 
title('SW high res max, min, and mask')
xlabel('igm index')
ylabel('igm count')
grid on; zoom on
saveas(gcf, 'igm_min_max_SW', 'png')

