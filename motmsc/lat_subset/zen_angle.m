%
% zen_angle  - plot AIRS and CrIS secant by scan angle
%

adir = '/asl/data/airs/L1C/2016/126';
agran = 'AIRS.2016.05.05.231.L1C.AIRS_Rad.v6.1.2.0.G16127122356.hdf';
afile = fullfile(adir, agran);
% scanang = hdfread(afile, 'scanang');
satzen  = hdfread(afile, 'satzen');

cdir = '/asl/data/cris/ccast/sdr60/2016/126';
cgran = 'SDR_d20160505_t0746285.mat';
cfile = fullfile(cdir, cgran);
d1 = load(cfile);

% sample AIRS zenith angles
airs_zen = satzen(20, :);
airs_sec = sec(deg2rad(airs_zen));

% sample CrIS zenith angles
ztmp = d1.geo.SatelliteZenithAngle;
cris_zen = squeeze(ztmp(:,:, 20));
cris_sec = sec(deg2rad(cris_zen));

% AIRS and CrIS scan indices
ia0 = 1:90;          % basic AIRS xtrack indices
ic1 = 1:30;          % basic CrIS FOR indices
ic2 = [8 23];        % CrIS midtrack subset
ia1 = ic1 * 3 - 1;   % AIRS indices for ic1 (basic CrIS FORs)
ia2 = ic2 * 3 - 1;   % AIRS indices for ic2 (CrIS midtrack subset)

figure(1); clf
subplot(2,1,1)
plot(ia0, airs_sec, '+k', ia1, cris_sec, 'og', ia2, cris_sec(:,ic2), '*')
title('AIRS and CrIS zenith secant by xtrack index')
legend('AIRS', 'CrIS', 'location', 'north')
% xlabel('AIRS xtrack index i, CrIS FOR floor(i/3)+1')
ylabel('secant')
grid on

subplot(2,1,2)
plot(ia0, airs_sec, '+k', ia1, cris_sec, 'og', ia2, cris_sec(:,ic2), '*')
axis([20, 70, 1, 1.2])
% title('detail of the above')
legend('AIRS', 'CrIS', 'location', 'north')
xlabel('AIRS xtrack index i, CrIS FOR floor(i/3)+1')
ylabel('secant')
grid on

