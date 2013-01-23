
% step thru all interferograms for the selected day and find max 
% and min values for real and imaginary components, for each band.

% These are saved for subsequent comparison

% select day-of-the-year
doy = '054';  % high-res 2nd day

% get a list of files for this day
fyear = '/home/motteler/cris/data/2012';  
fdir  = fullfile(fyear, doy);
flist = dir(fullfile(fdir, 'DMP*.mat'));
nfile = length(flist);

% initial load to get sizes
dfile = fullfile(fdir, flist(1).name);
load(dfile)

% initialize arrays
nptsLW = instLW.npts+2;
nptsMW = instMW.npts+2;
nptsSW = instSW.npts+2;

igm_maxLW = zeros(nptsLW, 1);
igm_minLW = zeros(nptsLW, 1);
igm_maxMW = zeros(nptsMW, 1);
igm_minMW = zeros(nptsMW, 1);
igm_maxSW = zeros(nptsSW, 1);
igm_minSW = zeros(nptsSW, 1);

% loop on files
for i = 1 : nfile
  dfile = fullfile(fdir, flist(i).name);
  load(dfile)
  [m,n,nobs] = size(igmLW);

  for j = 1 : nobs
    for k = 1 : 9
      igm_re = real(squeeze(igmLW(:, k, j)));
      igm_im = imag(squeeze(igmLW(:, k, j)));
      ix = find(igm_re > igm_maxLW);
      igm_maxLW(ix) = igm_re(ix);
      ix = find(igm_im > igm_maxLW);
      igm_maxLW(ix) = igm_im(ix);
      ix = find(igm_re < igm_minLW);
      igm_minLW(ix) = igm_re(ix);
      ix = find(igm_im < igm_minLW);
      igm_minLW(ix) = igm_im(ix);

      igm_re = real(squeeze(igmMW(:, k, j)));
      igm_im = imag(squeeze(igmMW(:, k, j)));
      ix = find(igm_re > igm_maxMW);
      igm_maxMW(ix) = igm_re(ix);
      ix = find(igm_im > igm_maxMW);
      igm_maxMW(ix) = igm_im(ix);
      ix = find(igm_re < igm_minMW);
      igm_minMW(ix) = igm_re(ix);
      ix = find(igm_im < igm_minMW);
      igm_minMW(ix) = igm_im(ix);

      igm_re = real(squeeze(igmSW(:, k, j)));
      igm_im = imag(squeeze(igmSW(:, k, j)));
      ix = find(igm_re > igm_maxSW);
      igm_maxSW(ix) = igm_re(ix);
      ix = find(igm_im > igm_maxSW);
      igm_maxSW(ix) = igm_im(ix);
      ix = find(igm_re < igm_minSW);
      igm_minSW(ix) = igm_re(ix);
      ix = find(igm_im < igm_minSW);
      igm_minSW(ix) = igm_im(ix);
    end
  end
end

save(['igm_min_max_',doy], 'instLW', 'instMW', 'instSW', ...
      'igm_maxLW', 'igm_maxMW', 'igm_maxSW', 'igm_minLW', ...
      'igm_minMW', 'igm_minSW', 'flist', 'nfile');

