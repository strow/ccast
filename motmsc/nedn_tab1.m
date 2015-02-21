%
% nedn_tab1 -- tabulate unfiltered nedn estimates
%

addpath ./utils
addpath ../source

% path to SDR year
syear = '/asl/data/cris/ccast/sdr60_hr_tmp/2015';

% SDR days of the year
sdays = 15 : 17;

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

save nedn_tab vLW vMW vSW nLWtab nMWtab nSWtab

