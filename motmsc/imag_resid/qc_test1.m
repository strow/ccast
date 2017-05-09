%
% qc_test1 - single test call of checkSDR
%

addpath utils
addpath imag_resid
addpath ../source

% bad
% rid = 'd20160120_t0032496'
  rid = 'd20160120_t0352485'

% good
% rid = 'd20160120_t1952431'
% rid = 'd20160120_t0848468'
% rid = 'd20160120_t1152458'
% rid = 'd20160120_t1208457'
% rid = 'd20160120_t1152458'

% doy = '018';
% doy = '019';
  doy = '020';

spath = '/asl/data/cris/ccast/sdr60_hr/2016';

sfile = fullfile(spath, doy, ['SDR_', rid, '.mat']);
load(sfile)

[L1b_err, L1b_stat] = ...
   checkSDR(vLW, vMW, vSW, rLW, rMW, rSW, cLW, cMW, cSW, L1a_err, rid);

