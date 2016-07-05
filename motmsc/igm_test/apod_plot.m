%
% apod_plot -- plot extended res cosine apodization
%

addpath ../source
addpath /home/motteler/matlab/export_fig

band = 'LW';
opt1 = struct;
opt1.inst_res = 'hires3';
opt1.user_res = 'hires';
wlaser = 773.13;
[inst, user] = inst_params(band, wlaser, opt1);

dx = inst.dx;
npts = inst.npts;
(npts - 12) * dx

w = 1:npts;
x = ones(npts, 1);
y = igm_apod(x, 7);

figure(1)
subplot(1,2,1)
plot(w, y, w(1:6), y(1:6), 'o')
axis([1, 7, 0, 1])
title([band,' left apod'])
xlabel('index')
ylabel('weight')
grid on; zoom on

subplot(1,2,2)
plot(w, y, w, y, 'o')
axis([npts-6, npts, 0, 1])
title([band,' right apod'])
xlabel('index')
grid on; zoom on

export_fig(['apod_', band, '.pdf'], '-m2', '-transparent')

