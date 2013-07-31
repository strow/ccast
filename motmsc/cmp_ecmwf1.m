%
% loop on ECMWF rtp files, match with IDPS rtp, do some sanity
% checks, and compare clear spectra
%

% paths to rtpread and rad2bt
addpath /home/motteler/mot2008/hdf/h4tools/
addpath /home/motteler/cris/bcast/source

% ECMWF rtp path, file prefix, file suffix
epath = '/asl/data/rtprod_cris/2013/01/20/';
epre = 'ecm.cris_sdr60_subset_noaa_ops.';
esuf = '.v1.rtpZ';

% IDPS rtp path, file prefix, file suffix
spath = epath;
spre = 'cris_sdr60_subset_noaa_ops.';
ssuf = '.v1.rtp';

% list of ECMWF rtp filenames
elist = dir(fullfile(epath, [epre, '*', esuf]));

% loop on ECMWF rtp files
for i = 1 : length(elist)

  ecmwf_rtp = fullfile(epath, elist(i).name);
  if exist(ecmwf_rtp) ~= 2, continue, end

  k = length(epre);
  rtp_id = elist(i).name(k+1 : k+13);
  sdr_rtp = fullfile(spath, [spre, rtp_id, ssuf]);
  if exist(sdr_rtp) ~= 2, continue, end

  % read the RTP files
  [ehead, ehattr, eprof, epattr] = rtpread(ecmwf_rtp);
  [shead, shattr, sprof, spattr] = rtpread(sdr_rtp);

  % sanity checks
  [ isequal(ehead.vchan, shead.vchan), ...
    isequal(eprof.rtime, sprof.rtime), ...
    isequal(eprof.ifov, sprof.ifov), ...
    isequal(eprof.xtrack, sprof.xtrack), ...
    isequal(eprof.plat, sprof.plat), ...
    isequal(eprof.plon, sprof.plon) ]

  % main channel set
  ix = 1 : 1305;

  % translate to brightness temps
  freq = ehead.vchan(ix);
  ebt = real(rad2bt(freq, eprof.rcalc(ix, :)));
  sbt = real(rad2bt(freq, sprof.robs1(ix, :)));

  % take a clear subset
  iclear = find(bitand(1, sprof.iudef(1,:)));
% iclear = find(sprof.iudef(1,:) == 1);
  iz = 1 : 20 : length(iclear);
  plot(freq, sbt(:,iclear(iz)) - ebt(:,iclear(iz)))
% plot(freq, sbt(:,iy))
% plot(freq, ebt(:,iy))
  pause

end

