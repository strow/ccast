%
% cris bandpass filter demo
%
% this version shows the full filter wings
%

addpath ../source

fig = 'png';
band = 'LW';
band = input('band > ', 's');
wlaser = 773.1301;
[inst, user] = inst_params(band, wlaser);

dv = user.dv;
vr = user.vr;
v1 = user.v1;
v2 = user.v2;
vL = inst.freq(1);
vU = inst.freq(end);
vL = round(vL/dv) * dv;
vU = round(vU/dv) * dv;
x1 = (vL : dv : vU)';
npts = length(x1);
y1 = ones(npts,1);
i1 = interp1(x1, (1:npts)', v1, 'nearest');
i2 = interp1(x1, (1:npts)', v2, 'nearest');
y1 = bandpass(x1, y1, v1, v2, vr);

figure(1); clf
subplot(1,2,1)
ix = 1:i1+4;
% jx = i1-4:i1;
% plot(x1(ix), y1(ix), x1(jx), 1, '+')
plot(x1(ix), y1(ix), vL, 0, 'o')
ax = axis; ax(4)=1.01; axis(ax);
title([band,' filter LHS'])
grid on;

subplot(1,2,2)
ix = i2-4:npts;
% jx = i2:i2+4;
% plot(x1(ix), y1(ix), x1(jx), 1, '+')
plot(x1(ix), y1(ix), vU, 0, 'o')
ax = axis; ax(4)=1.01; axis(ax);
title([band,' filter RHS'])
grid on

% saveas(gcf, ['filt_fig_2_', band], fig)

