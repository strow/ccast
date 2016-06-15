%
% a2_test -- FOV differences as a function of a2 values
%
% main internal vars
%   na2   -  number of a2 vals
%   a2wt  -  a2 scaling factors
%   bmLW  -  LW bt means, nchan x 9 x na2
%   bmMW  -  MW bt means, nchan x 9 x na2
%   bdif  -  all FOVs minus reference FOV 
%   brms  -  rms of diffs over fitting span
%

addpath utils

%-----------------
% test parameters
%-----------------

refFOV = 9;    % reference FOV
a2ref = 90;    % a2 factor for reference FOV, pct

testFOV = 7;              % test FOV (for diff plots)
a2test = [90, 95, 100];   % a2 factors for test FOV, pct

vL = 1250;    % MW fitting interval start, 1/cm
vH = 1750;    % MW fitting interval end, 1/cm

%--------------------------------------------
% tabulate means x FOVs x a2 scaling factors
%--------------------------------------------

% a2 scaling factors as strings
alist = {'040', '045', '050', '055', '060', '065', '070', '075', ...
         '080', '085', '090', '095', '100', '105', '110'};

% loop initialization
na2 = length(alist);
a2wt = [];
bmLW = []; 
bmMW = [];

% concatenate the test summaries
for i = 1 : na2
  a2wt = [a2wt; str2num(alist{i})];
  d = load(['mean_cfovs/ccast_h3a2', alist{i}, '_15-16.mat']);
  bmLW = cat(3, bmLW, d.bmLW);
  bmMW = cat(3, bmMW, d.bmMW);
end

% full frequency grids
vLW = d.vLW;
vMW = d.vMW;

% indexes of a2 reference and test value
ia2ref = interp1(a2wt, 1:na2, a2ref, 'nearest');
ia2test = interp1(a2wt, 1:na2, a2test, 'nearest');

% reference FOV diffs
[m, n, k] = size(bmMW);
bdif = zeros(m, n, k);
for i = 1 : n
  for j = 1 : k
    bdif(:, i, j) = bmMW(:, i, j) - bmMW(:, refFOV, ia2ref);
  end
end

% rms of diffs over fitting span
ix = vL <= vMW & vMW <= vH;
brms = squeeze(rms(bdif(ix,:,:)));
vrms = vMW(ix);

%-----------------------------------
% plot test FOV minus reference FOV 
%-----------------------------------

figure(1); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
plot(vMW, squeeze(bdif(:, testFOV, ia2test)))
% axis([1620, 1660, -0.6, 0.2])
  axis([1200, 1760, -0.6, 0.2])
title(sprintf('MW FOV %d a2 values minus FOV %d a2 %d pct', ...
               testFOV, refFOV, a2wt(ia2ref)))
legend(alist(ia2test(:)), 'location', 'southwest') 
xlabel('wavenumber')
ylabel('dBT')
grid on; zoom on
% saveas(gcf, sprintf('MW_FOV_%d-%d', testFOV, refFOV), 'png')

%----------------------------------
% plot rms residuals vs a2 factors
%----------------------------------

figure(2); clf
% set(gcf, 'Units','centimeters', 'Position', [4, 10, 24, 16])
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(a2wt, brms, 'linewidth', 2)
axis([a2wt(1), a2wt(end), 0, 0.15])
title(sprintf('MW residuals vs FOV %d a2 %d pct', refFOV, a2wt(ia2ref)))
legend(fovnames, 'location', 'northwest')
xlabel('a2 scaling factor, pct')
ylabel(sprintf('rms diff %d to %d 1/cm', vL, vH))
grid on; zoom on
% saveas(gcf, sprintf('MW_res_FOV_%d', refFOV), 'png')

