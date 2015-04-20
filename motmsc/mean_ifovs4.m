%
% mean_ifovs - compare noaa FOV means over a set of files
%
% specify a list of days, take the mean and standard deviation for
% selected FORs for each FOV, and compare these values with the the
% values for a selected FOV
%

addpath ../source
addpath ../motmsc/asl
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
% syear = '/asl/data/cris/sdr4/hires/2015';
  syear = '/asl/data/cris/sdr4/algo2/2015';

% SDR days of the year
sdays = 48 : 50;

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

    % get data for this band
    switch(band)
      case 'LW', rad1 = pd.ES_RealLW;
      case 'MW', rad1 = pd.ES_RealMW;
      case 'SW', rad1 = pd.ES_RealSW;
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
%       if L1a_err(sFOR(i), j)
%         continue
%       end
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
tstr = sprintf('%s_%s_%s', yr, seq2str(sdays), t2);

% print some test stats
fprintf(1, 'residuals by FOV\n')
fprintf(1, '%8.4f', rmscol(bavg - bavg(:,iref)*ones(1,9)))
fprintf(1, '\nnoaa %s FOV %d, test %s, bn = %d\n', band, iref, tstr, bn)

% save the data
clear bt1 bt2 geo pd
save(sprintf('noaa_%s_%s_%s', band, tstr, seq2str(sFOR)))

