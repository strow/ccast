%
% nedn_tab1 -- tabulate unfiltered nedn estimates
%
% This script tabulates the ccast NEdN fields nLW, nMW, and nSW 
% over multiple days, to be used to generate a principal component
% filter.  The ccast source data should be generated with the calmain
% nedn filtering statements temporarily commented out.  Output is
% saved to nedn_tab.mat

addpath ./utils
addpath ../source

% path to SDR year
% syear = '/asl/data/cris/ccast/sdr60_hr_pc/2015';
  syear = '/asl/data/cris/ccast/sdr60_pc/2014';

% SDR days of the year
% sdays = 46 : 48;
  sdays = 254 : 256;

nLWtab = [];
nMWtab = [];
nSWtab = [];

% loop on days
for di = sdays

  % loop on SDR files
  doy = sprintf('%03d', di);
  flist = dir(fullfile(syear, doy, ['SDR_*.mat']));
  for fi = 1 : length(flist);

    % load the SDR data
    rid = flist(fi).name(5:22);
    stmp = ['SDR_', rid, '.mat'];
    sfile = fullfile(syear, doy, stmp);
    load(sfile)

    nLWtab = cat(4, nLWtab, nLW);
    nMWtab = cat(4, nMWtab, nMW);
    nSWtab = cat(4, nSWtab, nSW);

    fprintf(1, '.')
  end
  fprintf(1, '\n')
end

% save nedn_tab_HR vLW vMW vSW nLWtab nMWtab nSWtab
  save nedn_tab_LR vLW vMW vSW nLWtab nMWtab nSWtab

