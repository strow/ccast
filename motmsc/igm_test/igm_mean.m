
% step thru all interferograms for the selected day and find the
% mean values for the real and imaginary components, for each band.
% These are saved for subsequent tests

% select day-of-the-year
doy = '054';  % high-res 2nd day

% get a list of files for this day
fyear = '/home/motteler/cris/data/2012';  
fdir  = fullfile(fyear, doy);
flist = dir(fullfile(fdir, 'DMP*.mat'));

% adjust flist as needed
flist = flist(1:end-2);   
nfile = length(flist);

% initial load to get sizes
dfile = fullfile(fdir, flist(1).name);
load(dfile)

% initialize averages
ntot = 0;
nptsLW = instLW.npts+2;
nptsMW = instMW.npts+2;
nptsSW = instSW.npts+2;

iavg_re_LW = zeros(nptsLW, 1);
iavg_im_LW = zeros(nptsLW, 1);
iavg_re_MW = zeros(nptsMW, 1);
iavg_im_MW = zeros(nptsMW, 1);
iavg_re_SW = zeros(nptsSW, 1);
iavg_im_SW = zeros(nptsSW, 1);

% loop on files
for i = 1 : nfile
  dfile = fullfile(fdir, flist(i).name);
  load(dfile)
  [m,n,nobs] = size(igmLW);

  for j = 1 : nobs
    for k = 1 : 9
      ntmp = ntot;
      igm_re_LW = real(squeeze(igmLW(:, k, j)));
      igm_im_LW = imag(squeeze(igmLW(:, k, j)));
      igm_re_MW = real(squeeze(igmMW(:, k, j)));
      igm_im_MW = imag(squeeze(igmMW(:, k, j)));
      igm_re_SW = real(squeeze(igmSW(:, k, j)));
      igm_im_SW = imag(squeeze(igmSW(:, k, j)));

      % check for bad data
      if sum(isnan(igm_re_LW)) || sum(isnan(igm_re_LW)) || ...
         sum(isnan(igm_re_MW)) || sum(isnan(igm_re_MW)) || ...
         sum(isnan(igm_re_SW)) || sum(isnan(igm_re_SW))
        continue
      end

      % update the averages
      [iavg_re_LW, ntot] = rec_mean(iavg_re_LW, ntmp, igm_re_LW);
      [iavg_im_LW, ntot] = rec_mean(iavg_im_LW, ntmp, igm_im_LW);
      [iavg_re_MW, ntot] = rec_mean(iavg_re_MW, ntmp, igm_re_MW);
      [iavg_im_MW, ntot] = rec_mean(iavg_im_MW, ntmp, igm_im_MW);
      [iavg_re_SW, ntot] = rec_mean(iavg_re_SW, ntmp, igm_re_SW);
      [iavg_im_SW, ntot] = rec_mean(iavg_im_SW, ntmp, igm_im_SW);
    end
  end
end

save(['igm_mean_',doy], 'instLW', 'instMW', 'instSW', ...
      'iavg_re_LW', 'iavg_im_LW', 'iavg_re_MW', 'iavg_im_MW', ...
      'iavg_re_SW', 'iavg_im_SW', 'flist', 'nfile', 'ntot');

