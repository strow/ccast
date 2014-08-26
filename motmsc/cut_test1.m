% 
% cut_test1 -- show plot channel freq vs met laser
%

band = 'SW';
opts = struct;
opts.resmode = 'hires2';

% met laser steps
wgrid = 773 : .001 : 774;

% get initial sensor grid
inst = inst_params(band, wgrid(1), opts);

% get a channel near the cut point
ichan = inst.npts - inst.cutpt ;
v = inst.freq(ichan);

% initialize arrays
n = length(wgrid);
vtab = zeros(n, 1);
ctab = zeros(n, 1);
itab = zeros(n, 1);
stab = zeros(n, 1);
etab = zeros(n, 1);

% loop on met laser steps
for i = 1 : n

  % sensor grid for this step
  inst = inst_params(band, wgrid(i), opts);

  % find current index for v
  ix = interp1(inst.freq, 1:inst.npts, v, 'nearest');
  v = inst.freq(ix);

  % save cut point, v, and ix
  ctab(i) = inst.cutpt;
  vtab(i) = v;
  itab(i) = ix;
  stab(i) = inst.freq(1);
  etab(i) = inst.freq(end);
end

figure(1); clf
subplot(2,1,1)
plot(wgrid, ctab)
title('transform cut points')
ylabel('index')
grid on; zoom on

subplot(2,1,2)
plot(wgrid(1:end-2), diff(diff(vtab)))
title('frequency shift')
xlabel('met laser')
ylabel('freq 2nd diff')
grid on; zoom on

figure(2); clf
subplot(2,1,1)
plot(wgrid, stab)
title('start frequency')
ylabel('wavenumber')
grid on; zoom on

subplot(2,1,2)
plot(wgrid, etab)
title('end frequency')
ylabel('wavenumber')
xlabel('met laser')
grid on; zoom on

% export_fig('fig_6.pdf', '-m2', '-transparent')

