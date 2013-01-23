
% test driver for sdr2rtp

% select day-of-the-year
% doy = '054';  % high-res 2nd day
% doy = '136';  % may 15 focus day
doy = 213;      % includes new geo

% path to matlab SDR input by day-of-year
SDR_mat = '/home/motteler/cris/data/2012';  

% path to matlab RTP output by day-of-year
RTP_mat = '/home/motteler/cris/data/2012rtp';  

% full path to matlab SDR input files
sdir = fullfile(SDR_mat, doy);

% full path to matlab RTP output files
rdir = fullfile(RTP_mat, doy);

% create the matlab RTP directory, if necessary
unix(['mkdir -p ', rdir]);

% get matlab SDR file list
flist = dir(fullfile(sdir, 'SDR*.mat'));

opts = struct;

[rlist, msc] = sdr2rtp(flist, sdir, rdir, opts)

