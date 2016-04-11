%
% ils_demo - demo ILS plots
%

addpath ../../source
addpath ../utils

band = 'SW';
wlaser = 773.13;
opts = struct;
opts.inst_res = 'hires3';
opts.user_res = 'hires';

[foax, frad] = fp_v33a(band);
[inst, user] = inst_params(band, wlaser, opts);
inst.foax = foax; 
inst.frad = frad;

k = 6;
v1 = user.v1;
v2 = user.v2;
vref = floor((v1 + v2) / 2);
vgrid = (vref - k : 0.02 : vref+k)';

opts.narc = 2000;
opts.wrap = 'psinc n';

srf1 = newILS(1, inst, vref, vgrid, opts);
srf2 = newILS(2, inst, vref, vgrid, opts);
srf5 = newILS(5, inst, vref, vgrid, opts);

figure(1); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
plot(vgrid, srf1, vgrid, srf2, vgrid, srf5)
axis([vgrid(1), vgrid(end), -0.3, 1.1])
title(sprintf('CrIS ILS at %g cm-1', vref))
legend('FOV 1', 'FOV 2', 'FOV 5')
xlabel('wavenumber');
ylabel('weight')
zoom on; grid on

% saveas(gcf, sprintf('ILS_%s_demo', band), 'png')
  export_fig(sprintf('ILS_%s_demo.pdf', band), '-m2', '-transparent')

