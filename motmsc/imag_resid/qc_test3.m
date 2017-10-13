%
% qc_test3 - comparis loop test for checkSDR vs checkSDRv1
%

addpath ../source
addpath ../motmsc/utils
addpath /asl/packages/airs_decon/source

% path to SDR year
% tstr = 'sdr60_hr';
  tstr = 'sdr60';
  year = '2017';
% year = '2016';

% SDR days of the year
% sdays =  48 : 50;   % 17-19 Feb 2015
% sdays =  18 : 20;   % 2016 noaa test days (many SW errors...)
  sdays = 31;
% sdays = 20;

tdir = '/asl/data/cris/ccast';
ydir = fullfile(tdir, tstr, year);

opts = struct;
opts.emax = 0;
opts.emsg = false;

% loop on days and files
for di = sdays

  % loop on SDR files
  doy = sprintf('%03d', di);
  flist = dir(fullfile(ydir, doy, 'SDR*.mat'));
  for fi = 1 : length(flist);

    % load the SDR data
    rid = flist(fi).name(5:22);
    stmp = ['SDR_', rid, '.mat'];
    sfile = fullfile(ydir, doy, stmp);
    load(sfile)

    [L1b_err1, L1b_stat1] = ...
      checkSDRv1(vLW, vMW, vSW, rLW, rMW, rSW, cLW, cMW, cSW, ...
                 L1a_err, rid, opts);

    [L1b_err2, L1b_stat2] = ...
      checkSDR(vLW, vMW, vSW, rLW, rMW, rSW, cLW, cMW, cSW, ...
               userLW, userMW, userSW, L1a_err, rid, opts);

%   if ~isequal(L1b_err1, L1b_err2)
    if ~isequal(L1b_stat1.imgLW, L1b_stat2.imgLW) | ...
       ~isequal(L1b_stat1.imgMW, L1b_stat2.imgMW) | ...
       ~isequal(L1b_stat1.imgSW, L1b_stat2.imgSW)

      display(['------- ',rid,' -------'])
      display('neg rad')
      display([isequal(L1b_stat1.negLW, L1b_stat2.negLW), ...
               isequal(L1b_stat1.negMW, L1b_stat2.negMW), ...
               isequal(L1b_stat1.negSW, L1b_stat2.negSW)])
      display('cal NaNs')
      display([isequal(L1b_stat1.nanLW, L1b_stat2.nanLW), ...
               isequal(L1b_stat1.nanMW, L1b_stat2.nanMW), ...
               isequal(L1b_stat1.nanSW, L1b_stat2.nanSW)])
      display('too hot')
      display([isequal(L1b_stat1.hotLW, L1b_stat2.hotLW), ...
               isequal(L1b_stat1.hotMW, L1b_stat2.hotMW), ...
               isequal(L1b_stat1.hotSW, L1b_stat2.hotSW)])
      display('imag resid')
      display([isequal(L1b_stat1.imgLW, L1b_stat2.imgLW), ...
               isequal(L1b_stat1.imgMW, L1b_stat2.imgMW), ...
               isequal(L1b_stat1.imgSW, L1b_stat2.imgSW)])
      display('old neg sum')
      display([sum(L1b_stat1.negLW(:)), ...
               sum(L1b_stat1.negMW(:)), ...
               sum(L1b_stat1.negSW(:))])
      display('old imag sum')
      display([sum(L1b_stat1.imgLW(:)), ...
               sum(L1b_stat1.imgMW(:)), ...
               sum(L1b_stat1.imgSW(:))])
      display('new imag sum')
      display([sum(L1b_stat2.imgLW(:)), ...
               sum(L1b_stat2.imgMW(:)), ...
               sum(L1b_stat2.imgSW(:))])
    end
  end
end

