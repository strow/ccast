%
% mean_cfovs - compare ccast FOV means over a set of files
%
% specify a set of days (or directories), take the mean and standard
% deviation for selected FORs for each FOV, and compare these values
% with the the values for a selected FOV
%

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
syear = '/asl/data/cris/ccast/sdr60_hr/2014';

% SDR days of the year
% sdays = 71;         % high res test 1
% sdays = 239 : 240;  % high res test 2
% sdays = 338 : 339;  % 4-5 dec 2014
  sdays = 340 : 342;  % 6-8 dec 2014

% get user grid 
opts = struct;
opts.resmode = res;
[inst, user] = inst_params(band, 774, opts);
nchan = round((user.v2 - user.v1) / user.dv) + 1;
vgrid = user.v1 + (0:nchan-1)' * user.dv;

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
  flist = dir(fullfile(syear, doy, 'SDR*.mat'));
  for fi = 1 : length(flist);

    % load the SDR data
    rid = flist(fi).name(5:22);
    stmp = ['SDR_', rid, '.mat'];
    sfile = fullfile(syear, doy, stmp);
    load(sfile)

    % get data and frequency grid for this band
    switch(band)
      case 'LW', rtmp = rLW; vtmp = vLW(:);
      case 'MW', rtmp = rMW; vtmp = vMW(:);
      case 'SW', rtmp = rSW; vtmp = vSW(:);
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
        if L1a_err(i, j)
          continue
        end
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
fprintf(1, '%8.4f', rmscol(bavg_diff))
fprintf(1, '\nccast %s FOV %d, test %s, bn = %d\n', band, iref, fsuf, bn)

% save the data
clear btmp rtmp geo rLW rMW rSW cLW cMW cSW
save(sprintf('ccast_%s_%s', band, fsuf))

