%
% mean_ifovs - compare noaa FOV means over a set of files
%
% specify a set of days (or directories), take the mean and standard
% deviation for selected FORs for each FOV, and compare these values
% with the the values for a selected FOV
%

addpath ./asl
addpath ./utils
addpath ../source

%-----------------
% test parameters
%-----------------
band = 'LW';
res = 'hires2';  % lowres, hires1, hires2
sFOR = 15:16;    % fields of regard, 1-30
aflag = 0;       % set to 1 for ascending
iref = 5;        % index of reference FOV

% path to SDR year
syear = '/asl/data/cris/sdr4/hires/2014';

% SDR days of the year
% sdays = 338 : 339;
  sdays = 340 : 342;

% get user grid
opts = struct;
opts.resmode = res;
[inst, user] = inst_params(band, 774, opts);
nchan = round((user.v2 - user.v1) / user.dv) + 1;
vgrid = user.v1 + (0:nchan-1) * user.dv;

% NOAA SDR channel frequencies
ng = 2;  % number of guard chans
n1 = round((user.v2 - user.v1) / user.dv) + 1;
vtmp = user.v1 - ng * user.dv + (0 : n1 + 2*ng -1) * user.dv;

% loop initialization
nFOR = numel(sFOR);
bm = zeros(nchan * 9, 1);
bw = zeros(nchan * 9, 1);
bn = 0;

%------------------------
% loop on days and files
%------------------------
for di = sdays

  % loop on SDR files
  doy = sprintf('%03d', di);
  flist = dir(fullfile(syear, doy, ['SCRIS_npp_*.h5']));
  for fi = 1 : length(flist);

    % read the next SDR file
    sid = flist(fi).name(11:28);
    sfile = fullfile(syear, doy, flist(fi).name);
    try 
      pd = readsdr_rawpd(sfile);
    catch
      fprintf(1, 'could not read %s\n', sfile);
      continue
    end

    % read the corresponding geo file
    glist = dir(fullfile(syear, doy, ['GCRSO_npp_', sid, '*.h5']));
    if isempty(glist)
      fprintf(1, 'no corresponding geo for %s\n', sid)
      continue
    end
    gtmp = glist(end).name;
    gfile = fullfile(syear, doy, gtmp);
    try
      [geo, gat1] = read_GCRSO(gfile);  
    catch
      fprintf(1, 'could not read %s\n', gfile);
      continue
    end

    % get data and frequency grid for this band
    switch(band)
      case 'LW', rtmp = pd.ES_RealLW;
      case 'MW', rtmp = pd.ES_RealMW;
      case 'SW', rtmp = pd.ES_RealSW;
    end

    % keep the standard user grid
    [m, n, k, nscan] = size(rtmp);
    [ix, jx] = seq_match(vgrid, vtmp);
    if ~isclose(vgrid, vtmp(jx))
      error('frequency grid mismatch')
    end

    % get BT, reshape for moving averages
    rtmp = rtmp(jx, :, sFOR, :);
    btmp = real(rad2bt(vgrid, rtmp));
    btmp = reshape(btmp, nchan * 9, nscan * nFOR);

    % get ascending flag for current scans
    atmp = lat2aflag(squeeze(geo.Latitude(5,15,:)));

    % loop on scans
    for j = 1 : nscan
      if atmp(j) ~= aflag
        continue
      end
      for i = 1 : nFOR
        k = nFOR * (j - 1) + i;
        if ~isempty(find(isnan(btmp(:, k))))
          continue
        end
        if ~isempty(find(btmp(:, k) > 320)) && strcmp(band, 'LW')
          continue
        end
        [bm, bw, bn] = rec_var(bm, bw, bn, btmp(:, k));
      end
    end
    fprintf(1, '.')
  end
  fprintf(1, '\n')
end

% reshape mean and std
bv = bw ./ (bn - 1);
bs = sqrt(bv);
bstd = reshape(bs, nchan, 9);
bavg = reshape(bm, nchan, 9);

% get relative differences
bavg_diff = bavg - bavg(:, iref) * ones(1, 9);
bstd_diff = bstd - bstd(:, iref) * ones(1, 9);

% save file suffix
[t1, yr] = fileparts(syear); 
[t1, t2] = fileparts(t1);
t2 = t2(6:end);
fsuf = sprintf('%s_%s%s', yr, seq2str(sdays), t2);

% print some test stats
fprintf(1, 'residuals by FOV\n')
fprintf(1, '%8.4f', rmscol(bavg - bavg(:,iref)*ones(1,9)))
fprintf(1, '\nnoaa %s FOV %d, test %s, bn = %d\n', band, iref, fsuf, bn)

% save the data
clear btmp rtmp geo pd
save(sprintf('noaa_%s_%s', band, fsuf))

