%
% call rdr2sdr4 on regular or high-res data
%

% select day-of-the-year
% doy = '054';  % high-res 2nd day
doy = '136';
% doy = '140';
% doy = '141';

% set bcast paths
addpath /home/motteler/cris/bcast
% addpath /home/motteler/cris/bcast/davet

% set RDR and SDR base paths
% RDR_HDF = '/asl/data/cris/rdr4/hdf/2012/';
RDR_mat = '/asl/data/cris/rdr4/mat/2012/';

% full path to matlab RDR files
rdir = fullfile(RDR_mat, doy);

% get matlab RDR file list
flist = dir(fullfile(rdir, 'RDR*.mat'));
% flist = flist(61:64);
% flist = flist(2:(end-1));

% profile clear
% profile on

msc = rdr2sdr4(flist, rdir);

% profile viewer

ms_hr = 1e3 * 60 * 60;

n = length(msc.tmin);

t0 = msc.tmin(1);

xx = msc.tmin(2:n) - msc.tmax(1:n-1);
min(xx)
max(xx)

plot(1:n, (msc.tmin-t0)/ms_hr, 1:n, (msc.tmax-t0)/ms_hr)
xlabel('index')
ylabel('hour')
grid
zoom on


