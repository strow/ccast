
% step thru all interferograms for the selected day and find the
% standard deviation for the real and imaginary components, for each
% band.  The results are saved to a file

% select day-of-the-year
doy = '054';  % high-res 2nd day

% get the means for the same data
d1 = load(['igm_mean_',doy]);

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

istd_re_LW = zeros(nptsLW, 1);
istd_im_LW = zeros(nptsLW, 1);
istd_re_MW = zeros(nptsMW, 1);
istd_im_MW = zeros(nptsMW, 1);
istd_re_SW = zeros(nptsSW, 1);
istd_im_SW = zeros(nptsSW, 1);

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

      % update the standard deviations
      [istd_re_LW, ntot] = rec_var(d1.iavg_re_LW, istd_re_LW, ntmp, igm_re_LW);
      [istd_im_LW, ntot] = rec_var(d1.iavg_im_LW, istd_im_LW, ntmp, igm_im_LW);
      [istd_re_MW, ntot] = rec_var(d1.iavg_re_MW, istd_re_MW, ntmp, igm_re_MW);
      [istd_im_MW, ntot] = rec_var(d1.iavg_im_MW, istd_im_MW, ntmp, igm_im_MW);
      [istd_re_SW, ntot] = rec_var(d1.iavg_re_SW, istd_re_SW, ntmp, igm_re_SW);
      [istd_im_SW, ntot] = rec_var(d1.iavg_im_SW, istd_im_SW, ntmp, igm_im_SW);
    end
  end
end

% note rec_var returns std^2
istd_re_LW = sqrt(istd_re_LW);
istd_im_LW = sqrt(istd_im_LW);
istd_re_MW = sqrt(istd_re_MW);
istd_im_MW = sqrt(istd_im_MW);
istd_re_SW = sqrt(istd_re_SW);
istd_im_SW = sqrt(istd_im_SW);

save(['igm_std_',doy], 'instLW', 'instMW', 'instSW', ...
      'istd_re_LW', 'istd_im_LW', 'istd_re_MW', 'istd_im_MW', ...
      'istd_re_SW', 'istd_im_SW', 'flist', 'nfile', 'ntot');

