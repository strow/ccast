%
% relative FOV differences over a day
%

addpath ../source
addpath ../motmsc/time
addpath ../motmsc/utils

% cdir = '/asl/data/cris/ccast/SDR_j01_s45/2018/006';
  cdir = '/asl/data/cris/ccast/SDR_j01_s45_fudge/2018/006';
flist = dir(fullfile(cdir, 'CrIS_SDR_j01_s45_*.mat'));

for fi = 1 : length(flist)

  d1 = load(fullfile(flist(fi).folder, flist(fi).name));

  if fi == 1
    nchan = length(d1.vLW);
    rsum = zeros(nchan, 9);
    rcnt = zeros(1, 9);
  end

  for iScan = 1 : 45
    for iFOR = 1 : 30
      for iFOV = 1 : 9
        if ~d1.L1b_err(iFOV,iFOR,iScan)
           rsum(:,iFOV) = rsum(:,iFOV) + d1.rLW(:,iFOV,iFOR,iScan);
           rcnt(1,iFOV) = rcnt(1,iFOV) + 1;
         end
       end
     end
   end

  fprintf(1, '.')
end
fprintf(1, '\n')

v = d1.vLW;
rmean = rsum ./ rcnt;

% save fov_mean_atbd_06 cdir v rmean
  save fov_mean_fudge_06 cdir v rmean

