%
% rad_svd1 -- SVD on some sample radiance sets
%

addpath ../source

% Sergio's SAF 704 profile set
sdir = '/home/sergio/MATLABCODE/REGR_PROFILES/RUN_KCARTA/SAF704/RAD1013';
r704 = zeros(2232, 704);
for i = 1 : 704
  smat = fullfile(sdir, ...
         sprintf('convolved_kcarta_RAD1013_%d_radiances.mat', i));
  d1 = load(smat);
  r704(:, i) = d1.rcris_all(2:2233, 1);
end
v704 = d1.fcris(2:2233);

% Scott's 49 fitting profiles
kcdir = '/home/motteler/cris/sergio/JUNK2012/';
flist =  dir(fullfile(kcdir, 'convolved_kcart*.mat'));

opts.user_res = 'hires';
opts.inst_res = 'hires3';
wlaser = 773.1301;  % nominal value
[instLW, userLW] = inst_params('LW', wlaser, opts);
[instMW, userMW] = inst_params('MW', wlaser, opts);
[instSW, userSW] = inst_params('SW', wlaser, opts);

r49 = [];
for i = 1 : length(flist)
  d1 = load(fullfile(kcdir, flist(i).name));
  vkc = d1.w(:); rkc = d1.r(:);

  if i == 8, continue, end

  % convolve kcarta radiances to CrIS channels
  [rLW, vLW] = kc2cris(userLW, rkc, vkc);
  [rMW, vMW] = kc2cris(userMW, rkc, vkc);
  [rSW, vSW] = kc2cris(userSW, rkc, vkc);

  r49 = [r49, [rLW; rMW; rSW]];
  v49 = [vLW; vMW; vSW];

  fprintf(1, '.');
end
fprintf(1, '\n')

d1 = load('cal_flat');
r3782 = [d1.radLW; d1.radMW; d1.radSW];
v3782 = [d1.frqLW; d1.frqMW; d1.frqSW];
clear d1

% stats
b49   = real(rad2bt(v49, r49));
b704  = real(rad2bt(v704, r704));
b3782 = real(rad2bt(v3782, r3782));

[u1,s1,v1] = svd(r49, 0);
[u2,s2,v2] = svd(r704, 0);
[u3,s3,v3] = svd(r3782, 0);

% [u1,s1,v1] = svd(b49, 0);
% [u2,s2,v2] = svd(b704, 0);
% [u3,s3,v3] = svd(b3782, 0);

s1 = diag(s1);
s2 = diag(s2);
s3 = diag(s3);

ix = 400;
% semilogy(1:49, s1, 1:ix, s2(1:ix), 1:ix, s3(1:ix))
loglog(1:48, s1, 1:ix, s2(1:ix), 1:ix, s3(1:ix), 'linewidth', 2)
% axis([0, ix, 1e-2, 1e5])
title(sprintf('first %d singular values for 3 radiance sets', ix))
legend('Scott 49 fitting', 'Sergio new 704', 'clear gran 3782')
xlabel('singular value index')
ylabel('singular values')
grid on; zoom on

% saveas(gcf, 'sing_vals', 'png')

d1 = 48;
r49b = u1(:, 1:d1) * u1(:, 1:d1)' * r49;
b49b = real(rad2bt(v49, r49b));
rms(b49(:) - b49b(:))

d2 = 202
r704b = u2(:, 1:d2) * u2(:, 1:d2)' * r704;
b704b = real(rad2bt(v704, r704b));
rms(b704(:) - b704b(:))

d3 = 39;
r3782b = u3(:, 1:d3) * u3(:, 1:d3)' * r3782;
b3782b = real(rad2bt(v3782, r3782b));
rms(b3782(:) - b3782b(:))

