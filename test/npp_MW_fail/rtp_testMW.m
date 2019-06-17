%
%  4-way comparison of ccast ref, ccast a4, noaa a4, and rtp data
%

addpath ../source
addpath ../motmsc/time
addpath ../motmsc/utils
addpath /asl/packages/iasi_decon
addpath /asl/packages/airs_decon/source
addpath /asl/matlib/h4tools

jFOV = 7;   % select a FOV
jdir = 1;   % select sweep direction (0 or 1)
hapod = 1;  % specify apodization

if true
  dstr = '3 Mar 2019'; fstr = 'pre_fail';
  p1 = '/home/motteler/cris/move_data/npp_scrif/2019/062';
  gn = 'GCRSO-SCRIF_npp_d20190303_t2103039_e2111017_b38072_c20190507191924162690_nobc_ops.h5';
  p2 = './ccast_a4_test_a2_new_ict/sdr45_npp_HR/2019/062';
  p3 = './ccast_a4_uw_a2_new_ict/sdr45_npp_HR/2019/062';
  gc = 'CrIS_SDR_npp_s45_d20190303_t2106080_g212_v20a.mat';
  rdir = '/asl/rtp/rtp_cris_ccast_hires/clear/2019/062';
  rfile = 'cris_ecmwf_isarta_clear_g212_d20190303.rtp';
else
  dstr = '21 Apr 2019'; fstr = 'post_fail';
  p1 = '/home/motteler/cris/move_data/npp_scrif/2019/111';
  gn = 'GCRSO-SCRIF_npp_d20190421_t0952319_e1000297_b38760_c20190506160940749526_noac_ops.h5';
  p2 = './ccast_ref_eng_a2_new_ict/sdr45_npp_HR/2019/111';
  p3 = './ccast_a4_eng_a2_new_ict/sdr45_npp_HR/2019/111';
  gc = 'CrIS_SDR_npp_s45_d20190421_t0948080_g099_v20a.mat';
  rdir = '/asl/rtp/rtp_cris_ccast_hires/clear/2019/111';
  rfile = 'cris_ecmwf_isarta_clear_g099_d20190421.rtp';
end

% load noaa data
f1 = fullfile(p1, gn);
d1 = read_SCRIF(f1);
gx = read_GCRSO(f1);

% load ccast data
f2 = fullfile(p2, gc);
f3 = fullfile(p3, gc);
d2 = load(f2);
d3 = load(f3);

tn = double(gx.FORTime);      % noaa IET time
tc = d2.geo.FORTime;          % ccast IET time
% t3 = d3.geo.FORTime;        % duplicate ccast time
% isequal(tc, t3)             % sanity check
tn = iet2tai(tn);             % ccast TAI
tc = iet2tai(tc);             % noaa TAI
vMW = d2.vMW;  vSW = d2.vSW;  % ccast and noaa freq

% load rtp data
rfile = fullfile(rdir, rfile);
[head, hattr, prof, pattr] = rtpread_new(rfile);

% % run iasi2cris on sarta rtp data
% opt1 = struct;
% opt1.user_res = 'hires';
% opt1.nguard = 0;
% opt1.hapod = hapod;
% [crad, cfreq] = iasi2cris(prof.rclr, head.vchan, opt1);
% crad = real(crad);
% % plot(cfreq, real(rad2bt(cfreq, crad(:, 1:10))))

% take FOV and sweep direction subset of the rtp data
ix1 = find(prof.ifov == jFOV & mod(prof.xtrack, 2) == jdir);
nr = length(ix1);
if nr == 0
  fprintf(1, 'no rtp obs selected\n')
  return
else
  fprintf(1, 'selected %d rtp obs\n', nr)
end

tr = prof.rtime(ix1);       % rtp time after subset
% rad4 = crad(:, ix1);      % sarta/iasi2cris radiance
rad4 = prof.rclr(:, ix1);   % sarta/iasi2cris radiance
if hapod, rad4 = hamm_app(rad4); end
rad5 = prof.robs1(:, ix1);  % rtp observed radiance
ifov = prof.ifov(ix1);      % rtp FOV index
xtrack = prof.xtrack(ix1);  % rtp FOR index
vchan = head.vchan;         % rtp frequency
% bt4 = real(rad2bt(cfreq, rad4));
bt4 = real(rad2bt(vchan, rad4));
bt5 = real(rad2bt(vchan, rad5));

fprintf(1, 'granule time spans\n')
display(['noaa  ', datestr(tai2dnum(tn(1))), '  ', datestr(tai2dnum(tn(end)))])
display(['ccast ', datestr(tai2dnum(tc(1))), '  ', datestr(tai2dnum(tc(end)))])
display(['rtp   ', datestr(tai2dnum(tr(1))), '  ', datestr(tai2dnum(tr(end)))])

[jn, jc] = seq_match(tn(:), tc(:), 0.01);
fprintf(1, 'found %d noaa/ccast matches\n', length(jn))

rn = mod(jn-1, 30) + 1;      % noaa row index
rc = mod(jc-1, 30) + 1;      % ccast row index
cn = floor((jn-1)/30) + 1;   % noaa col index
cc = floor((jc-1)/30) + 1;   % ccast col index
% isequal(double(gx.FORTime(rn, cn)), d2.geo.FORTime(rc, cc))

% more granule info
i = floor(length(rn)/2);
tsn = datestr(iet2dnum(gx.FORTime(rn(i), cn(i))));
tsc = datestr(iet2dnum(d2.geo.FORTime(rc(i), cc(i))));
lat = gx.Latitude(5, rn(i), cn(i));
lon = gx.Longitude(5, rn(i), cn(i));
fmt1 = 'noaa/ccast match midpt FOR %d, %s, lat %3.1f lon %3.1f\n';
fprintf(1, fmt1, rn(i), tsn, lat, lon);

% loop on noaa/ccast jFOV matchups 
bt1 = []; bt2 = []; bt3 = [];
cr1 = []; cr2 = []; cr3 = [];
tm = [];

for i = 1 : length(cn)

% % skip if wrong sweep direction
% if mod(rn(i),2) ~= jdir, continue, end

  % sanity check
  if rn(i) ~= rc(i), error('FOR mismatch'), end

  rad1 = d1.ES_RealMW(:, jFOV, rn(i), cn(i));
  rad2 = d2.rMW(:, jFOV, rc(i), cc(i));
  rad3 = d3.rMW(:, jFOV, rc(i), cc(i));

  if hapod
    rad1 = hamm_app(double(rad1));
    rad2 = hamm_app(double(rad2));
    rad3 = hamm_app(double(rad3));
  end

  bt1 = [bt1, rad2bt(vMW, rad1)];  % noaa a4
  bt2 = [bt2, rad2bt(vMW, rad2)];  % ccast ref
  bt3 = [bt3, rad2bt(vMW, rad3)];  % ccast a4

  cr1 = [cr1, d1.ES_ImaginaryMW(:, jFOV, rn(i), cn(i))];
  cr2 = [cr2, d2.cMW(:, jFOV, rc(i), cc(i))];
  cr3 = [cr3, d3.cMW(:, jFOV, rc(i), cc(i))];

  tm = [tm, iet2tai(d2.geo.FORTime(rc(i), cc(i)))];
end

% % check rtp vs ccast obs
% [im, ir] = seq_match(tm, tr, 0.01);
% [jx1, jx2] = seq_match(vMW, vchan, 0.05);
% fprintf(1, '%d noaa/ccast/rtp matchups\n', length(im));
% vx1 = vMW(jx1);
% % vx2 = vchan(jx2);
% % isequal(vx1, vx2)
% bt2 = bt2(jx1, im);
% bt5 = bt5(jx2, ir);
% figure(1); clf
% plot(vx1, bt2 - bt5)
% return

% match rtp with noaa/ccast matchups
[im, ir] = seq_match(tm, tr, 0.01);
% [jx1, jx2] = seq_match(vMW, cfreq, 0.05);
[jx1, jx2] = seq_match(vMW, vchan, 0.05);
vx1 = vMW(jx1);
% vx2 = cfreq(jx2);
nm = length(im);
if nm == 0
  fprintf(1, 'no noaa/ccast/rtp matchups\n')
  return
else
  fprintf(1, 'found %d noaa/ccast/rtp matchups\n', nm)
end

bt1 = bt1(jx1, im);
bt2 = bt2(jx1, im);
bt3 = bt3(jx1, im);
cr1 = cr1(jx1, im);
cr2 = cr2(jx1, im);
cr3 = cr3(jx1, im);
bt4 = bt4(jx2, ir);

btm1 = mean(bt1, 2);  % noaa a4
btm2 = mean(bt2, 2);  % ccast ref
btm3 = mean(bt3, 2);  % ccast a4
btm4 = mean(bt4, 2);  % sarta/decon
crm1 = mean(cr1, 2);
crm2 = mean(cr2, 2);
crm3 = mean(cr3, 2);
crs1 = std(cr1, 0, 2);
crs2 = std(cr2, 0, 2);
crs3 = std(cr3, 0, 2);

figure(1)
subplot(3,1,1)
plot(vx1, btm1, vx1, btm2, vx1, btm3)
% axis([650, 1100, 200, 300])
title(sprintf('%s MW BT mean, FOV %d sweep %d', dstr, jFOV, jdir))
legend('noaa a4', 'ccast ref', 'ccast a4', 'location', 'south')
ylabel('BT (K)')
grid on; zoom on

subplot(3,1,2)
plot(vx1, btm1 - btm2)
% axis([650, 1100, -0.2, 0.2])
title('noaa minus ccast ref')
ylabel('dBT (K)')
grid on; zoom on

subplot(3,1,3)
plot(vx1, btm1 - btm3)
% axis([650, 1100, -0.2, 0.2])
title('noaa minus ccast a4')
xlabel('wavenumber (cm-1)')
ylabel('dBT (K)')
grid on; zoom on
s1 = sprintf('MW_%s_BT_fov%d_sd%d', fstr, jFOV, jdir);
% saveas(gcf, s1, 'fig')

figure(2)
subplot(2,1,1)
plot(vx1, crm1, vx1, crm2, vx1, crm3)
% axis([650, 1100, -0.4, 0.4])
title(sprintf('%s MW imag resid mean, FOV %d sweep %d', dstr, jFOV, jdir))
legend('noaa a4', 'ccast ref', 'ccast a4')
ylabel('mw sr-1 m-2')
grid on; zoom on

subplot(2,1,2)
plot(vx1, crs1, vx1, crs2, vx1, crs3)
% axis([650, 1100, 0, 0.25])
title(sprintf('MW imag resid std, FOV %d sweep %d', jFOV, jdir))
legend('noaa a4', 'ccast ref', 'ccast a4')
ylabel('mw sr-1 m-2')
xlabel('wavenumber (cm-1)')
grid on; zoom on
s2 = sprintf('MW_%s_imag_fov%d_sd%d', fstr, jFOV, jdir);
% saveas(gcf, s2, 'fig')

figure(3)
plot(vx1, btm1 - btm4, vx1, btm2 - btm4, vx1, btm3 - btm4)
% axis([650, 1100, -1, 1]);
%   axis([650, 680, -0.8, 1.4])
axis([1200,1750,-2, 1])
% axis([1530, 1570, -0.6, 0.6])
% title(sprintf('%s sarta comparisons, FOV %d sweep %d', dstr, jFOV, jdir))
% legend('noaa a4 minus sarta', 'ccast ref minus sarta', ...
%        'ccast a4 minus sarta', 'location', 'southeast');
title(sprintf('%s sarta comparisons, FOV %d', dstr, jFOV))
legend('noaa a4 eng a2', 'ccast a4 umbc FOV 7', ...
       'ccast a4 uw new FOV 7', 'location', 'southwest')

grid on; zoom on
s3 = sprintf('MW_%s_sarta_fov%d_sd%d', fstr, jFOV, jdir);
% saveas(gcf, s3, 'fig')

% save sarta diffs
% sx = sprintf('sarta_%s_apod%d_fov%d_sd%d', ...
%               fstr, hapod, jFOV, jdir);
% save(sx, 'vx1', 'btm1', 'btm2', 'btm3', 'btm4');
%
