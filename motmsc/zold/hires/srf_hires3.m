
% check high res SA residuals

% specify file, FOR, scan, and plot file ID
% sfile = '/home/motteler/cris/data/2012/054/SDR_d20120223_t0033314.mat';
sfile = '/home/motteler/cris/data/2012/054/SDR_d20120223_t1505265.mat';
scan = 58;
iFOR = 15;
iFOV = 5;

% get the data
load(sfile)

% select a radiance
r1 = rSW(:, iFOV, iFOR, scan);
n1 = length(vSW);
v1 = vSW;

load ../inst_data/SRF_v33aHR_SW.mat
S1 = squeeze(s(1).stab(:,:,1));
S2 = squeeze(s(1).stab(:,:,2));
S5 = squeeze(s(1).stab(:,:,5));

% SRF frequency grid
v2 = s(1).vobs;  
n2 = length(v2);
dv = v2(2) - v2(1);

% interpolate FOV 5 obs to SRF freq grid
[rx, vx] = finterp(r1, v1, dv);

% embed r2 in (larger) SRF freq grid
ix = interp1(v2, 1:n2, vx+1e-8, 'nearest');
r2 = zeros(n2, 1);
r2(ix) = rx;

% max(abs(v2(ix) - vx'))
% plot(v1, r1, v2, r2)
% legend('bcast obs', 'interp obs')
% grid on; zoom on

figure(1); clf
subplot(2,1,1)
q = S1 * r2;
r3 = inv(S1) * q;
plot(v2, (r2 - r3)/rms(r2))
title('FOV 1 SW high res residual')
grid on; zoom on

subplot(2,1,2)
q = S2 * r2;
r3 = inv(S2) * q;
plot(v2, (r2 - r3)/rms(r2))
title('FOV 2 SW high res residual')
grid on; zoom on
saveas(gcf, 'hires_resid', 'fig')

