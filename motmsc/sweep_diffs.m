%
% sweep_diffs -- compare space and IT looks by sweep direction
%
% run interactively from calmain 
%

addpath utils
addpath /asl/matlib/fileexchange/export_fig

% get mean space and IT looks for this granule
sp1 = mean(abs(pcorr2(squeeze(avgSP(:, :, 1, :)))), 3);
sp2 = mean(abs(pcorr2(squeeze(avgSP(:, :, 2, :)))), 3);
% it1 = mean(abs(pcorr2(squeeze(avgIT(:, :, 1, :)))), 3);
% it2 = mean(abs(pcorr2(squeeze(avgIT(:, :, 2, :)))), 3);

% apply SA-1 to the mean space and IT looks
[m, n] = size(sp1);
spc1 = zeros(m, n);
spc2 = zeros(m, n);
itc1 = zeros(m, n);
itc2 = zeros(m, n);
for fi = 1 : 9
   spc1(:,fi) = Sinv(:,:,fi) * sp1(:,fi);
   spc2(:,fi) = Sinv(:,:,fi) * sp2(:,fi);
%  itc1(:,fi) = Sinv(:,:,fi) * it1(:,fi);
%  itc2(:,fi) = Sinv(:,:,fi) * it2(:,fi);
end

% plot scales
switch(upper(band))
  case 'LW', ps = 0.01;
  case 'MW', ps = 0.02;
  case 'SW', ps = 0.06;
end

figure(1); clf
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(vinst, spc1)
legend(fovnames, 'location', 'northeast')
title(sprintf('%s uncorrected SP1', band))
xlabel('frequency')
ylabel('count spectra')
grid on; zoom on

figure(2); clf
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(vinst, spc1)
legend(fovnames, 'location', 'northeast')
title(sprintf('%s with SA-1 SP1', band))
xlabel('frequency')
ylabel('count spectra')
grid on; zoom on

figure(3); clf
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(vinst, (sp2 - sp1) ./ sp1)
axis([user.v1, user.v2, -ps, ps])
legend(fovnames, 'location', 'northwest')
title(sprintf('%s uncorrected (SP2 - SP1) / SP1', band))
xlabel('frequency')
ylabel('relative difference')
grid on; zoom on

figure(4); clf
set(gcf, 'DefaultAxesColorOrder', fovcolors);
plot(vinst, (spc2 - spc1) ./ spc1)
axis([user.v1, user.v2, -ps, ps])
legend(fovnames, 'location', 'northwest')
title(sprintf('%s with SA-1 (SP2 - SP1) / SP1', band))
xlabel('frequency')
ylabel('relative difference')
grid on; zoom on

figure(5); clf
fn = fovnames;
fc = fovcolors;
ix = [1 3 7 9]; 
set(gcf, 'DefaultAxesColorOrder', fc(ix,:));
plot(vinst, (spc2(:,ix) - spc1(:,ix)) ./ spc1(:,ix))
axis([user.v1, user.v2, -ps, ps])
legend({fn{ix}}, 'location', 'northwest')
title(sprintf('%s with SA-1 (SP2 - SP1) / SP1', band))
xlabel('frequency')
ylabel('relative difference')
grid on; zoom on

figure(6); clf
ix = [2 4 6 8];
set(gcf, 'DefaultAxesColorOrder', fc(ix,:));
plot(vinst, (spc2(:,ix) - spc1(:,ix)) ./ spc1(:,ix))
axis([user.v1, user.v2, -ps, ps])
legend({fn{ix}}, 'location', 'northwest')
title(sprintf('%s with SA-1 (SP2 - SP1) / SP1', band))
xlabel('frequency')
ylabel('relative difference')
grid on; zoom on

figure(7); clf
ix = [5];
set(gcf, 'DefaultAxesColorOrder', fc(ix,:));
plot(vinst, (spc2(:,ix) - spc1(:,ix)) ./ spc1(:,ix))
axis([user.v1, user.v2, -ps, ps])
legend({fn{ix}}, 'location', 'northwest')
title(sprintf('%s with SA-1 (SP2 - SP1) / SP1', band))
xlabel('frequency')
ylabel('relative difference')
grid on; zoom on
