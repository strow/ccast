
%
% plot xtrack by atrack real and complex components for a selected
% channel
%
% this version loops on matlab SDR files with tiling code from the
% old rdr2spec5.m


% select day-of-the-year
% doy = '054';  % high-res 2nd day
% doy = '136';  % may 15 focus day
doy = '228';      % includes new geo

% path to matlab SDR input by day-of-year
SDR_mat = '/home/motteler/cris/data/2012';  

% full path to matlab SDR input files
sdir = fullfile(SDR_mat, doy);

% get matlab SDR file list
flist = dir(fullfile(sdir, 'SDR*.mat'));
nfile = length(flist);

% loop on matlab SDR files
% for si = 1 : nfile

% choose a single SDR file
for si = 61;

  % full path to matlab SDR file
  rid = flist(si).name(5:22);
  stmp = ['SDR_', rid, '.mat'];
  sfile = fullfile(sdir, stmp);

  load(sfile)

  [m, nscan] = size(scTime);

  % select a channel
  ch = 373;

  % tile the FOVs
  img_re = zeros(90,3*nscan);
  img_im = zeros(90,3*nscan);
  for i = 1 : nscan
    for j = 1 : 30
      t_re = reshape(squeeze(real(rLW(ch,:,j,i))), 3, 3);
      t_im = reshape(squeeze(imag(rLW(ch,:,j,i))), 3, 3);
      ix = 3*(j-1)+1;
      iy = 3*(i-1)+1;
      img_re(ix:ix+2, iy:iy+2) = t_re;
      img_im(ix:ix+2, iy:iy+2) = t_im;
    end
  end

  figure (1)
  imagesc(img_re')
  title([rid(2:9), ' ', rid(12:17), ' real'])
  xlabel('cross track FOV')
  ylabel('along track FOV')
  colorbar
% saveas(gcf, [rid(11:17), 'real'], 'fig')

  figure(2)
  imagesc(img_im')
  title([rid(2:9), ' ', rid(12:17), ' imag'])
  xlabel('cross track FOV')
  ylabel('along track FOV')
  colorbar
% saveas(gcf, [rid(11:17), 'imag'], 'fig')

% pause

end

