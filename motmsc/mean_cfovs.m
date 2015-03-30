%
% mean_cfovs - compare ccast FOV means over a set of files
%
% specify a list of days, take the mean and standard deviation for
% selected FORs for each FOV, and compare these values with the the
% values for a selected FOV
%

addpath ../source
addpath ../motmsc/utils

%-----------------
% test parameters
%-----------------
band = 'LW';
res = 'hires2';  % lowres, hires1, hires2
% sFOR = 15:16;  % fields of regard, 1-30
  sFOR = 16;     % fields of regard, 1-30
aflag = 0;       % set to 1 for ascending
iref = 5;        % index of reference FOV

% path to SDR year
syear = '/asl/data/cris/ccast/sdr60_hr/2015';

% SDR days of the year
% sdays = 71;         % high res test 1
% sdays = 239 : 240;  % high res test 2
% sdays = 340 : 342;  % 6-8 dec 2014
  sdays =  48 :  50;  % 17-19 Feb 2015

% get user grid
opts = struct;
opts.resmode = res;
[inst, user] = inst_params(band, 774, opts);
vgrid = cris_ugrid(user, 2);
nchan = length(vgrid);

% loop initialization
nFOR = length(sFOR);
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

    % get data for this band
    switch(band)
      case 'LW', rad1 = rLW; clear rLW
      case 'MW', rad1 = rMW; clear rMW
      case 'SW', rad1 = rSW; clear rSW
    end
    [m, n, k, nscan] = size(rad1);

    % get brightness temps of rad1 subset
    bt1 = real(rad2bt(vgrid, rad1(:, :, sFOR, :)));
    clear rad1

    % get ascending flag for current scans
    atmp = lat2aflag(squeeze(geo.Latitude(5, sFOR(1), :)));

    % loop on scans
    for j = 1 : nscan
      if isnan(atmp(j)) || atmp(j) ~= aflag
        continue
      end
      % loop on selected FORs
      for i = 1 : nFOR
        if L1a_err(sFOR(i), j)
          continue
        end
        bt2 = reshape(bt1(:, :, i, j), nchan * 9, 1);
        if ~isempty(find(isnan(bt2)))
          continue
        end
        [bm, bw, bn] = rec_var(bm, bw, bn, bt2);
      end
    end
    fprintf(1, '.')
  end
  fprintf(1, '\n')
end

% get variance and std
bv = bw ./ (bn - 1);
bs = sqrt(bv);

% reshape mean and std
bstd = reshape(bs, nchan, 9);
bavg = reshape(bm, nchan, 9);

% get relative differences
bavg_diff = bavg - bavg(:, iref) * ones(1, 9);
bstd_diff = bstd - bstd(:, iref) * ones(1, 9);

% save file suffix
[t1, yr] = fileparts(syear); 
[t1, t2] = fileparts(t1);
t2 = t2(6:end);
tstr = sprintf('%s_%s%s', yr, seq2str(sdays), t2);

% print some test stats
fprintf(1, 'residuals by FOV\n')
fprintf(1, '%8.4f', rmscol(bavg_diff))
fprintf(1, '\nccast %s FOV %d, test %s, bn = %d\n', band, iref, tstr, bn)

% save the data
clear bt1 bt2 geo rLW rMW rSW cLW cMW cSW
save(sprintf('ccast_%s_%s_%s', band, tstr, seq2str(sFOR)))

