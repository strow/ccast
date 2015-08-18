%
% check_days -- quick check for bad SDR data
%

addpath ../source
addpath ../motmsc/utils

%-----------------
% test parameters
%-----------------

% path to SDR year
% tstr = 'e5_Pn_ag';
% syear = fullfile('/asl/data/cris/ccast', tstr, '2015');
  syear = '/asl/data/cris/ccast/sdr60/2014';

% SDR days of the year
% sdays =  48 :  50;  % 17-19 Feb 2015
  sdays = 127 : 128;

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

    % loop on scans
    [m, n, k, nscan] = size(rLW);
    for j = 1 : nscan
      nbad = sum(L1a_err(:, j));
      if nbad > 0
        fprintf(1, 'day %d file %s scan %d: %d bad FORs\n', ...
                di, rid, j, nbad);
      end
    end 
  end
end

