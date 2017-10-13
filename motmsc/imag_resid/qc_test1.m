%
% qc_test1 - single test call of checkSDR
%

addpath utils
addpath imag_resid
addpath ../source

% tstr = 'sdr60_hr'
  tstr = 'sdr60'
year = '2016';
doy = '020';
tdir = '/asl/data/cris/ccast';

rbad = {
  'd20160120_t0032496',
  'd20160120_t0352485',
  'd20160120_t0216490',
  'd20160120_t0400484',
  'd20160120_t0536479',
  'd20160120_t0544478',
  'd20160120_t0352485',
  'd20160120_t0400484',
  'd20160120_t0536479',
  'd20160120_t0544478',
  'd20160120_t1048461',
  'd20160120_t1056461',
  'd20160120_t1224456',
  'd20160120_t1728439',
  'd20160120_t1904433'};

rgood = {
  'd20160120_t1952431',
  'd20160120_t0848468',
  'd20160120_t1152458',
  'd20160120_t1208457',
  'd20160120_t1152458'};

rlist = rbad;

for i = 1 : length(rlist)

  sfile = fullfile(tdir, tstr, year, doy, ['SDR_', rlist{i}, '.mat']);
  load(sfile)
  
  [L1b_err2, L1b_stat2] = ...
     checkSDR(vLW, vMW, vSW, rLW, rMW, rSW, cLW, cMW, cSW, ...
              userLW, userMW, userSW, L1a_err, rid);
  
  display('neg rad')
  display([isequal(L1b_stat.negLW, L1b_stat2.negLW), ...
           isequal(L1b_stat.negMW, L1b_stat2.negMW), ...
           isequal(L1b_stat.negSW, L1b_stat2.negSW)])
  
  display('cal NaNs')
  display([isequal(L1b_stat.nanLW, L1b_stat2.nanLW), ...
           isequal(L1b_stat.nanMW, L1b_stat2.nanMW), ...
           isequal(L1b_stat.nanSW, L1b_stat2.nanSW)])
  
  display('too hot')
  display([isequal(L1b_stat.hotLW, L1b_stat2.hotLW), ...
           isequal(L1b_stat.hotMW, L1b_stat2.hotMW), ...
           isequal(L1b_stat.hotSW, L1b_stat2.hotSW)])
  
  display('imag resid')
  display([isequal(L1b_stat.imgLW, L1b_stat2.imgLW), ...
           isequal(L1b_stat.imgMW, L1b_stat2.imgMW), ...
           isequal(L1b_stat.imgSW, L1b_stat2.imgSW)])
  
  display('old imag sum')
  display([sum(L1b_stat.imgLW(:)), ...
           sum(L1b_stat.imgMW(:)), ...
           sum(L1b_stat.imgSW(:))])
  
  display('new imag sum')
  display([sum(L1b_stat2.imgLW(:)), ...
           sum(L1b_stat2.imgMW(:)), ...
           sum(L1b_stat2.imgSW(:))])
  
  isequal(L1b_err, L1b_err2)

  input('continue > ');
end

