%
% a2_test -- FOV differences as a function of a2 values
%
% main internal vars
%   na2   -  number of a2 vals
%   a2wt  -  a2 scaling factors
%   bmLW  -  LW bt means, nchan x 9 x na2
%   dref  -  all FOVs minus reference FOV 
%   brms  -  rms of dref over fitting span
%   bfit  -  all FOVS fitted to reference FOV
%   dfit  -  fitted FOVs minus reference FOV 
%

function a2_test2(refFOV, a2ref)

addpath mean_cfovs
addpath ../motmsc/utils
addpath /home/motteler/matlab/export_fig

%-----------------
% test parameters
%-----------------

% reference FOV and a2 value
% refFOV = 5;
% a2ref = 90;

% test FOV and a2 values for spectra plots
testFOV = 9;              
a2test = [90, 100, 110];

% LW fitting interval
vL = 660; 
vH = 1060;

%--------------------------------------------
% tabulate means x FOVs x a2 scaling factors
%--------------------------------------------

% a2 scaling factors as strings
alist = {'040', '045', '050', '055', ...
         '060', '065', '070', '075', '080', '085', '090', '095', ...
         '100', '105', '110', '115', '120'};

% loop initialization
na2 = length(alist);
a2wt = [];
bmLW = [];

% concatenate the test summaries
for i = 1 : na2
  a2wt = [a2wt; str2num(alist{i})];
  d = load(['mean_cfovs/ccast_h3a2', alist{i}, '_15-16.mat']);
  bmLW = cat(3, bmLW, d.bmLW);
end

% full frequency grids
vLW = d.vLW;
ix = vL <= vLW & vLW <= vH;

% indexes of a2 reference and test value
ia2ref  = interp1(a2wt, 1:na2, a2ref,  'nearest');
ia2test = interp1(a2wt, 1:na2, a2test, 'nearest');

% fit all FOVs to the reference FOV
[m, n, k] = size(bmLW);
bfit = zeros(m, n, k);
wa = zeros(n, k); 
wb = zeros(n, k);
for i = 1 : n
  for j = 1 : k
    bref = bmLW(ix, refFOV, ia2ref);
    btmp = bmLW(ix, i, j);
    X2 = [btmp, ones(length(btmp), 1)] \ bref;
    wa(i, j) = X2(1); wb(i, j) = X2(2);
    bfit(:, i, j) = wa(i, j) * bmLW(:, i, j) + wb(i, j);
  end
end

% reference FOV diffs
[m, n, k] = size(bmLW);
dref = zeros(m, n, k);
dfit = zeros(m, n, k);
for i = 1 : n
  for j = 1 : k
    dref(:, i, j) = bmLW(:, i, j) - bmLW(:, refFOV, ia2ref);
    dfit(:, i, j) = bfit(:, i, j) - bmLW(:, refFOV, ia2ref);
  end
end

% rms of diffs over fitting span
brms = squeeze(rms(dref(ix, :, :)));

% summary stats in tabular form
[tm, im] = min(brms');
fprintf(1, 'FOV%3d  vs %4d%6d%6d%6d%6d%6d%6d%6d%6d\n', refFOV, 1:9)
fprintf(1, 'a2 %3d  vs %4d%6d%6d%6d%6d%6d%6d%6d%6d\n', a2ref, a2wt(im))
fprintf(1, 'min x 100'), fprintf(1, '%6.2f', tm * 100)
fprintf(1, '  %6.2f\n', sum(tm * 100))

%----------------------------------
% plot rms residuals vs a2 factors
%----------------------------------

figure(1); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(a2wt, brms, 'linewidth', 2)
axis([a2wt(1), a2wt(end), 0, 0.15])
title(sprintf('LW residuals vs FOV %d a2 %d pct', refFOV, a2wt(ia2ref)))
legend(fovnames, 'location', 'northwest')
xlabel('a2 scaling factor, pct')
ylabel(sprintf('rms diff %d to %d 1/cm', vL, vH))
grid on; zoom on

fstr1 = sprintf('LW_resids_FOV_%d_a2_%d', refFOV, a2wt(ia2ref));
% saveas(gcf, fstr1, 'png')
% export_fig([fstr1,'.pdf'], '-m2', '-transparent')

%------------------------------------
% plot test FOVs minus reference FOV 
%------------------------------------

figure(2); clf
set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
plot(vLW, squeeze(dref(:, testFOV, ia2test)))
  axis([700, 760, -0.2, 0.15])
% axis([650, 1100, -0.2, 0.2])
title(sprintf('LW FOV %d a2 values minus FOV %d a2 %d pct', ...
               testFOV, refFOV, a2wt(ia2ref)))
legend(alist(ia2test(:)), 'location', 'southwest') 
xlabel('wavenumber')
ylabel('dBT')
grid on; zoom on

fstr2 = sprintf('LW_FOV_%d_minus_%d_a2_%d', testFOV, refFOV, a2wt(ia2ref));
% saveas(gcf, fstr2, 'png')
% export_fig([fstr2,'.pdf'], '-m2', '-transparent')

return

%--------------------------------------
% plot fitted FOVs minus reference FOV 
%--------------------------------------

figure(3); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
plot(vLW, squeeze(dfit(:, testFOV, ia2test)))
  axis([700, 800, -0.2, 0.2])
% axis([650, 1100, -0.2, 0.2])
title(sprintf('LW FOV %d a2 values minus FOV %d a2 %d pct', ...
               testFOV, refFOV, a2wt(ia2ref)))
legend(alist(ia2test(:)), 'location', 'southwest') 
xlabel('wavenumber')
ylabel('dBT')
grid on; zoom on

