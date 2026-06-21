%
% compare ecmwf, idps, and ccast radiances
%

%--------------------------
% load rtp and bcast files
%--------------------------

% paths to rtpread and rad2bt
addpath /home/motteler/mot2008/hdf/h4tools/
addpath /home/motteler/cris/bcast/source
addpath utils

% bcast SDR path and day-of-the-year
doy = '020';
byear = '/asl/data/cris/ccast/sdr60/2013';  
bdir  = fullfile(byear, doy);
blist = dir(fullfile(bdir, 'SDR*.mat')); 

% choose and load a bcast file
% fi = 57;
fi = 69;
% fi = 120;
rid = blist(fi).name(5:22);
bfile = fullfile(bdir, blist(fi).name);
b1 = load(bfile);

% ECMWF rtp path, file prefix, file suffix
epath = '/asl/data/rtprod_cris_0/2013/01/20/';
epre = 'ecm.cris_sdr60_subset_noaa_ops.';
esuf = '.v1.rtpZ';
elist = dir(fullfile(epath, [epre, '*', esuf]));

% IDPS rtp path, file prefix, file suffix
spath = epath;
spre = 'cris_sdr60_subset_noaa_ops.';
ssuf = '.v1.rtp';

% choose and load an ecmwf rtp file
% fi = 8;
fi = 10;
% fi = 16;
ecmwf_rtp = fullfile(epath, elist(fi).name);
if exist(ecmwf_rtp) ~= 2, error('no ecmwf file'), end

k = length(epre);
rtp_id = elist(fi).name(k+1 : k+13);
sdr_rtp = fullfile(spath, [spre, rtp_id, ssuf]);
if exist(sdr_rtp) ~= 2, error('no idps file'), end

% read the RTP files
[ehead, ehattr, eprof, epattr] = rtpread(ecmwf_rtp);
[shead, shattr, sprof, spattr] = rtpread(sdr_rtp);

% RTP sanity checks
[ isequal(ehead.vchan, shead.vchan), ...
  isequal(eprof.rtime, sprof.rtime), ...
  isequal(eprof.ifov, sprof.ifov), ...
  isequal(eprof.xtrack, sprof.xtrack), ...
  isequal(eprof.plat, sprof.plat), ...
  isequal(eprof.plon, sprof.plon) ]

%---------------------
% match clear subsets
%---------------------

% choose a FOV
ifov = 1;

% get the rtp clear subset
iclear = find(bitand(1, sprof.iudef(1,:)));

% irok is the rtp index for clear obs for the selected FOV
irok = iclear(find(sprof.ifov(iclear) == ifov));
jrok = find(bitand(1, sprof.iudef(1,:)) & sprof.ifov == ifov);
isequal(irok, jrok)

% ibok is the index into valid bcast times
tt = b1.scTime(1:30,:);
ibok = find(~isnan(tt(:)));

% get rtp and bcast times
rt = tai2mat(eprof.rtime(irok)');
bt = iet2mat(b1.geo.FORTime(ibok));

% show file start and end times
datestr(rt(1)), datestr(rt(end)), datestr(bt(1)), datestr(bt(end))

% match rtp and bcast times
dt = 1/(24 * 60 * 60 * 100);  % 10 ms in matlab time
[irm, ibm] = seq_match(rt, bt, dt);

% see what FORs were selected
% [m,n] = size(b1.scTime);
% iFOR = (1:30)' * ones(1, n);
% iFOR(ibok(ibm))

%----------------------
% plot the LW matchups
%----------------------

% main rtp LW channel set
irchan = 1 : 713;

% matching bcast channel set
wlaser = 773.1301; band = 'LW';
[inst, user] = inst_params(band, wlaser);
ibchan = find(user.v1 <= b1.vLW & b1.vLW <= user.v2);

% take common radiance subsets
erad = eprof.rcalc(irchan, irok(irm));
srad = sprof.robs1(irchan, irok(irm));
brad = squeeze(b1.rLW(ibchan, ifov, ibok(ibm)));

% apodize obs
[m,n] = size(srad);
H = mkhamm(m);
srad = H * srad;
brad = H * brad;

% translate to brightness temps
rfreq = ehead.vchan(irchan);
ebt = real(rad2bt(rfreq, erad));
sbt = real(rad2bt(rfreq, srad));

bfreq = b1.vLW(ibchan)';
bbt = real(rad2bt(bfreq, brad));
% whos ebt sbt bbt
% isequal(bfreq, rfreq)

figure(1); clf
[m,n] = size(bbt);
y1 = mean(bbt - ebt, 2);
y2 = mean(sbt - ebt, 2);
y3 = mean(bbt - sbt, 2);
plot(bfreq, y1, bfreq, y2, bfreq, y3)
legend('bcast - ecmwf', 'idps - ecmwf', 'bcast - idps', 'location', 'best')
title(sprintf('%s FOV %d, %d matchups', strrep(rid, '_', ' '), ifov, n));
grid on; zoom on
saveas(gcf, [rid, '_LW'], 'png')

%----------------------
% plot the SW matchups
%----------------------

% main rtp SW channel set
irchan = 1147 : 1305;

% matching bcast channel set
wlaser = 773.1301; band = 'SW';
[inst, user] = inst_params(band, wlaser);
ibchan = find(user.v1 <= b1.vSW & b1.vSW <= user.v2);

% take common radiance subsets
erad = eprof.rcalc(irchan, irok(irm));
srad = sprof.robs1(irchan, irok(irm));
brad = squeeze(b1.rSW(ibchan, ifov, ibok(ibm)));

% apodize obs
[m,n] = size(srad);
H = mkhamm(m);
srad = H * srad;
brad = H * brad;

% translate to brightness temps
rfreq = ehead.vchan(irchan);
ebt = real(rad2bt(rfreq, erad));
sbt = real(rad2bt(rfreq, srad));

bfreq = b1.vSW(ibchan)';
bbt = real(rad2bt(bfreq, brad));
whos ebt sbt bbt
isequal(bfreq, rfreq)

figure(2); clf
[m,n] = size(bbt);
y1 = mean(bbt - ebt, 2);
y2 = mean(sbt - ebt, 2);
y3 = mean(bbt - sbt, 2);
plot(bfreq, y1, bfreq, y2, bfreq, y3)
legend('bcast - ecmwf', 'idps - ecmwf', 'bcast - idps', 'location', 'best')
title(sprintf('%s FOV %d, %d matchups', strrep(rid, '_', ' '), ifov, n));
grid on; zoom on
saveas(gcf, [rid, '_SW'], 'png')

