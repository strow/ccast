%
% qc_test2 - simple test loop for checkSDR
%

addpath ../source
addpath ../motmsc/utils
addpath /asl/packages/airs_decon/source

% path to SDR year
  tstr = 'sdr60_hr';
% tstr = 'sdr60';
syear = fullfile('/asl/data/cris/ccast', tstr, '2016');

% SDR days of the year
% sdays =  48 : 50;   % 17-19 Feb 2015
% sdays =  18 : 20;   % 2016 noaa test days (many SW errors...)
  sdays = 20;
% sdays =  61 : 63;   % 1-3 march

opts = struct;
opts.emsg = false;

profile clear
profile on

% loop on days and files
for di = sdays

  % loop on SDR files
  doy = sprintf('%03d', di);
  flist = dir(fullfile(syear, doy, 'SDR*.mat'));
  for fi = 1 : length(flist);

    % load the SDR data
    rid = flist(fi).name(5:22);
    stmp = ['SDR_', rid, '.mat'];
    sfile = fullfile(syear, doy, stmp);
    load(sfile)

    L1b_err = ...
      checkSDR(vLW, vMW, vSW, rLW, rMW, rSW, cLW, cMW, cSW, ...
               userLW, userMW, userSW, L1a_err, rid, opts);

  end
end

profile report

